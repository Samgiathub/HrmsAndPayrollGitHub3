
CREATE PROCEDURE [dbo].[P0110_Uniform_Dispatch_Detail]
    @Uni_Disp_Id	numeric(18, 0)	output,
    @Uni_Apr_Id	numeric(18, 0)	,
    @Uni_Req_App_Id	numeric(18, 0)	,
    @Uni_Req_App_Detail_Id	numeric(18, 0)	,
    @CMP_ID	numeric(18, 0)	,
    @Emp_ID	numeric(18, 0)	,
    @Dispatch_Code	numeric(18, 0)	,
    @Dispatch_Date	datetime	,
    @Refund_Installment	int	,
    @Deduction_Installment	int	,
    @Refund_Start_Date	datetime	,
    @Deduction_Start_Date	datetime	,
    @Dispatch_By_Emp_ID	numeric(18, 0)	,
    @Comments	nvarchar(250)	,
    @TranType Varchar(1),
	@User_Id numeric(18, 0),
	@IP_Address nvarchar(50)
	
AS  
	SET NOCOUNT ON   
	Declare @Old_Uni_Disp_Id numeric(18, 0)
    Declare @Old_Uni_Apr_Id numeric(18, 0)
	Declare @Old_Uni_Req_App_Id	numeric(18, 0)	
	Declare @Old_Uni_Req_App_Detail_Id	numeric(18, 0)	
	Declare @Old_CMP_ID	numeric(18, 0)	
	Declare @Old_Emp_ID	numeric(18, 0)	
	Declare @Old_Dispatch_Code	numeric(18, 0)	
	Declare @Old_Deduction_Start_Date	datetime	
	Declare @Old_Refund_Start_Date	datetime	
	Declare @Old_Dispatch_By_Emp_ID	numeric(18, 0)	
	Declare @Old_Comments	nvarchar(250)	
	Declare @Old_Systemdate	nvarchar(250)	
	Declare @Old_Refund_Installment	int	
    Declare @Old_Deduction_Installment	int
    Declare @OldValue nvarchar(max)

	SET @Old_Uni_Disp_Id=0
	SET @Old_Uni_Apr_Id=0
	SET @Old_Uni_Req_App_Id = 0
	SET @Old_Uni_Req_App_Detail_Id  = 0
	SET @Old_CMP_ID  = 0	
	SET @Old_Emp_ID  = 0
	SET @Old_Dispatch_Code  = 0
	SET @Old_Deduction_Start_Date  = null
	SET @Old_Refund_Start_Date  = null
	SET @Old_Dispatch_By_Emp_ID  = 0
	SET @Old_Systemdate=null
	SET @Old_Refund_Installment=0
	SET @Old_Deduction_Installment=0
	
    SET @Old_Comments=''
    
	IF @Uni_Req_App_Id =0  
		SET @Uni_Req_App_Id = null  
     
	IF @Uni_Req_App_Detail_Id = 0   
		SET @Uni_Req_App_Detail_Id =null  
		
	IF @Old_Dispatch_By_Emp_ID=0
		SET @Old_Dispatch_By_Emp_ID=null

	IF @Dispatch_By_Emp_ID=0
		SET @Dispatch_By_Emp_ID=null
	
	IF @Old_Uni_Disp_Id=0
		SET @Old_Uni_Disp_Id=null
		
	IF @TranType  = 'I'  
		BEGIN    
			   IF EXISTS(SELECT 1 
						 FROM T0110_UNIFORM_DISPATCH_DETAIL WITH (NOLOCK) 
						 WHERE Uni_Req_App_Detail_Id=@Uni_Req_App_Detail_Id 
							   AND Emp_ID=@EMP_ID and CMP_ID=@Cmp_ID)
				BEGIN				
				   SELECT @Uni_Disp_Id=Uni_Disp_Id 
				   FROM T0110_UNIFORM_DISPATCH_DETAIL WITH (NOLOCK) 
				   WHERE Uni_Req_App_Detail_Id=@Uni_Req_App_Detail_Id AND Emp_ID=@EMP_ID and CMP_ID=@Cmp_ID
				   RETURN
				END 
				SET @OldValue =  'New Value # Uni_Apr_Id : ' + convert(nvarchar(10),ISNULL(@Uni_Apr_Id,0))
							+ ' # Uni_Req_App_Detail_Id : ' + convert(nvarchar(10),ISNULL(@Uni_Req_App_Detail_Id,0))  
								+ ' # Uni_Disp_Id : ' + convert(nvarchar(10),ISNULL(@Uni_Disp_Id,0)) 
								+ ' # Cmp Id : ' + convert(nvarchar(10),ISNULL(@CMP_ID,0)) 
								+' # Emp Id : ' + convert(nvarchar(10),ISNULL(@Emp_ID,0)) +
								+ ' # Dispatch Code : ' + convert(nvarchar(10),ISNULL(@Dispatch_Code,0))
								+ ' # Refund Installment : ' + convert(nvarchar(10),ISNULL(@Refund_Installment,0)) 
								+ ' # Deduction Installment : ' + convert(nvarchar(10),ISNULL(@Deduction_Installment,0))  
								+ ' # Refund Start Date: '  +  CASE ISNULL(@Refund_Start_Date,0) WHEN 0 THEN '' ELSE convert(nvarchar(21),@Refund_Start_Date) END 
								+ ' # Deduction Start Date : ' +  CASE ISNULL(@Deduction_Start_Date,0) WHEN 0 THEN '' ELSE convert(nvarchar(21),@Deduction_Start_Date) END 
				--				+ ' # System Date : ' + CASE ISNULL(CONVERT(Date, CONVERT(VARCHAR(10), getdate(), 111)),0) WHEN 0 THEN '' ELSE convert(nvarchar(21),CONVERT(Date, CONVERT(VARCHAR(10), getdate(), 111))) END 
							 + ' # Dispatch By Emp ID : ' + convert(nvarchar(10),ISNULL(@Dispatch_By_Emp_ID,0)) 
								+ ' # Comments : ' + ISNULL(@Comments,'')
			
			
			INSERT INTO T0110_UNIFORM_DISPATCH_DETAIL  
					(Uni_Apr_Id,Uni_Req_App_Id,Uni_Req_App_Detail_Id,CMP_ID,Emp_ID,Dispatch_Code,Dispatch_Date,Refund_Installment,Deduction_Installment,Refund_Start_Date,Deduction_Start_Date,Dispatch_By_Emp_ID,System_Datetime,Comments,Ip_Address)                
			VALUES  (@Uni_Apr_Id,@Uni_Req_App_Id,@Uni_Req_App_Detail_Id,@CMP_ID,@Emp_ID,@Dispatch_Code,CONVERT(Date, CONVERT(VARCHAR(10), @Dispatch_Date, 111)),@Refund_Installment,@Deduction_Installment,CONVERT(Date, CONVERT(VARCHAR(10), @Refund_Start_Date, 111)), CONVERT(Date, CONVERT(VARCHAR(10), @Deduction_Start_Date, 111)),@Dispatch_By_Emp_ID,CONVERT(Date, CONVERT(VARCHAR(10), getdate(), 111)),@Comments,@IP_Address)   
		
			EXEC P9999_Audit_Trail @Cmp_ID,@TranType,'Uniform Requestition Dispatch',@OldValue,@Emp_ID,@User_Id,@IP_Address,1
		   
		END  
	ELSE IF @TranType = 'U'  
		BEGIN  
			SELECT  @Old_Uni_Apr_Id=Uni_Apr_Id,
					@Old_Uni_Req_App_Id=Uni_Req_App_Id,
					@Old_Uni_Disp_Id=Uni_Disp_Id,
					@Old_Uni_Req_App_Detail_Id=Uni_Req_App_Detail_Id,
					@Old_CMP_ID=CMP_ID,
					@Old_Emp_ID=Emp_ID,
					@Old_Dispatch_Code=Dispatch_Code,
					@Old_Deduction_Start_Date=Deduction_Start_Date,
					@Old_Refund_Start_Date=Refund_Start_Date,
					@Old_Dispatch_By_Emp_ID=Dispatch_By_Emp_ID,
					@Old_Systemdate=System_Datetime,
					@Old_Refund_Installment=Refund_Installment,
					@Old_Deduction_Installment=Deduction_Installment,
					@Old_Comments=Comments
			FROM T0110_UNIFORM_DISPATCH_DETAIL WITH (NOLOCK) 
			WHERE  Uni_Disp_Id = @Uni_Disp_Id
				
			SET @OldValue = ' old Value # Uni_Apr_Id : ' + convert(nvarchar(10),ISNULL(@Old_Uni_Apr_Id,0))
							+ ' # Uni_Req_App_Detail_Id : ' + convert(nvarchar(10),ISNULL(@Old_Uni_Req_App_Detail_Id,0))  
							+ ' # Uni_Disp_Id : ' + convert(nvarchar(10),ISNULL(@Old_Uni_Disp_Id,0)) 
							+ ' # Cmp Id : ' + convert(nvarchar(10),ISNULL(@Old_CMP_ID,0)) 
							+ ' # Emp Id : ' + convert(nvarchar(10),ISNULL(@Old_Emp_ID,0)) +
							+ ' # Dispatch Code : ' + convert(nvarchar(10),ISNULL(@Old_Dispatch_Code,0))
							+ ' # Refund Installment : ' + convert(nvarchar(10),ISNULL(@Old_Refund_Installment,0)) 
							+ ' # Deduction Installment : ' + convert(nvarchar(10),ISNULL(@Old_Deduction_Installment,0))  
							+ ' # Refund Start Date: '  +  CASE ISNULL(@Old_Refund_Start_Date,0) WHEN 0 THEN '' ELSE convert(nvarchar(21),@Old_Refund_Start_Date) END 
							+ ' # Deduction Start Date : ' +  CASE ISNULL(@Old_Deduction_Start_Date,0) WHEN 0 THEN '' ELSE convert(nvarchar(21),@Old_Deduction_Start_Date) END 
							+ ' # System Date : ' + CASE ISNULL(@Old_Systemdate,0) WHEN 0 THEN '' ELSE convert(nvarchar(21),@Old_Systemdate) END 
							+ ' # Dispatch By Emp ID : ' + convert(nvarchar(10),ISNULL(@Old_Dispatch_By_Emp_ID,0)) 
							+ ' # Comments : ' + ISNULL(@Old_Comments,'') 
							+ ' # New Value # Uni_Apr_Id : ' + convert(nvarchar(10),ISNULL(@Uni_Apr_Id,0))
							+ ' # Uni_Req_App_Detail_Id : ' + convert(nvarchar(10),ISNULL(@Uni_Req_App_Detail_Id,0))  
							+ ' # Uni_Disp_Id : ' + convert(nvarchar(10),ISNULL(@Uni_Disp_Id,0)) 
							+ ' # Cmp Id : ' + convert(nvarchar(10),ISNULL(@CMP_ID,0)) 
							+ ' # Emp Id : ' + convert(nvarchar(10),ISNULL(@Emp_ID,0)) +
							+ ' # Dispatch Code : ' + convert(nvarchar(10),ISNULL(@Dispatch_Code,0))
							+ ' # Refund Installment : ' + convert(nvarchar(10),ISNULL(@Refund_Installment,0)) 
							+ ' # Deduction Installment : ' + convert(nvarchar(10),ISNULL(@Deduction_Installment,0))  
							+ ' # Refund Start Date: '  +  CASE ISNULL(@Refund_Start_Date,0) WHEN 0 THEN '' ELSE convert(nvarchar(21),@Refund_Start_Date) END 
							+ ' # Deduction Start Date : ' +  CASE ISNULL(@Deduction_Start_Date,0) WHEN 0 THEN '' ELSE convert(nvarchar(21),@Deduction_Start_Date) END 
							--+ ' # System Date : ' + CASE ISNULL(CONVERT(Date, CONVERT(VARCHAR(10), getdate(), 111)),0) WHEN 0 THEN '' ELSE convert(nvarchar(21),CONVERT(Date, CONVERT(VARCHAR(10), getdate(), 111))) END 
							+ ' # Dispatch By Emp ID : ' + convert(nvarchar(10),ISNULL(@Dispatch_By_Emp_ID,0)) 
							+ ' # Comments : ' + ISNULL(@Comments,'')
					
			UPDATE  T0110_UNIFORM_DISPATCH_DETAIL  
			SET		Uni_Apr_Id=@Uni_Apr_Id,
					Uni_Req_App_Id=@Uni_Req_App_Id,
					Uni_Req_App_Detail_Id=@Uni_Req_App_Detail_Id,
					CMP_ID=@CMP_ID,
					Emp_ID=@Emp_ID,
					Dispatch_Code=@Dispatch_Code,
					Dispatch_Date=@Dispatch_Date,
					Refund_Installment=@Refund_Installment,
					Deduction_Installment=@Deduction_Installment,
					Refund_Start_Date=@Refund_Start_Date,
					Deduction_Start_Date=@Deduction_Start_Date,
					Dispatch_By_Emp_ID=@Dispatch_By_Emp_ID,
					System_Datetime=CONVERT(Date, CONVERT(VARCHAR(10), getdate(), 111)),
					Comments=@Comments,
					Ip_Address=@IP_Address
			WHERE  Uni_Disp_Id = @Uni_Disp_Id
				
		    EXEC P9999_Audit_Trail @Cmp_ID,@TranType,'Uniform Requestition Dispatch',@OldValue,@Emp_ID,@User_Id,@IP_Address,1
		   
		END
	ELSE IF @TranType = 'D'
		BEGIN

				IF EXISTS(SELECT 1 FROM T0140_Uniform_Payment_Transcation UP WITH (NOLOCK)
							  INNER JOIN T0100_Uniform_Emp_Issue UEI WITH (NOLOCK) ON UP.Uni_Apr_Id =UEI.Uni_Apr_Id
							  Where UEI.New_Req_Apr_Id=@Old_Uni_Apr_Id And (Uni_Credit <> 0 or Uni_Debit <> 0)
							 )
				BEGIN
					RAISERROR('@@Uniform Payment/Refund exists So Uniform Dispatch can not be delete.@@',16,2)
					return
				END

		SELECT  @Old_Uni_Apr_Id=Uni_Apr_Id,
					@Old_Uni_Req_App_Id=Uni_Req_App_Id,
					@Old_Uni_Disp_Id=Uni_Disp_Id,
					@Old_Uni_Req_App_Detail_Id=Uni_Req_App_Detail_Id,
					@Old_CMP_ID=CMP_ID,
					@Old_Emp_ID=Emp_ID,
					@Old_Dispatch_Code=Dispatch_Code,
					@Old_Deduction_Start_Date=Deduction_Start_Date,
					@Old_Refund_Start_Date=Refund_Start_Date,
					@Old_Dispatch_By_Emp_ID=Dispatch_By_Emp_ID,
					@Old_Systemdate=System_Datetime,
					@Old_Refund_Installment=Refund_Installment,
					@Old_Deduction_Installment=Deduction_Installment,
					@Old_Comments=Comments
			FROM T0110_UNIFORM_DISPATCH_DETAIL WITH (NOLOCK) 
			WHERE  Uni_Disp_Id = @Uni_Disp_Id
			
		    SET @OldValue = ' old Value # Uni_Apr_Id : ' + convert(nvarchar(10),ISNULL(@Old_Uni_Apr_Id,''))
							+ ' # Uni_Req_App_Detail_Id : ' + convert(nvarchar(10),ISNULL(@Old_Uni_Req_App_Detail_Id,''))  
							+ ' # Uni_Disp_Id : ' + convert(nvarchar(10),ISNULL(@Old_Uni_Disp_Id,'')) 
							+ ' # Cmp Id : ' + convert(nvarchar(10),ISNULL(@Old_CMP_ID,'')) 
							+ ' # Emp Id : ' + convert(nvarchar(10),ISNULL(@Old_Emp_ID,'')) +
							+ ' # Dispatch Code : ' + convert(nvarchar(10),ISNULL(@Old_Dispatch_Code,''))
							+ ' # Refund Installment : ' + convert(nvarchar(10),ISNULL(@Old_Refund_Installment,'')) 
							+ ' # Deduction Installment : ' + convert(nvarchar(10),ISNULL(@Old_Deduction_Installment,''))  
							+ ' # Refund Start Date: '  +  CASE ISNULL(@Old_Refund_Start_Date,'') WHEN '' THEN '' ELSE convert(nvarchar(21),@Old_Refund_Start_Date) END 
							+ ' # Deduction Start Date : ' +  CASE ISNULL(@Old_Deduction_Start_Date,'') WHEN '' THEN '' ELSE convert(nvarchar(21),@Old_Deduction_Start_Date) END 
							+ ' # System Date : ' + CASE ISNULL(@Old_Systemdate,'') WHEN '' THEN '' ELSE convert(nvarchar(21),@Old_Systemdate) END 
							--+ ' # Dispatch By Emp ID : ' + convert(nvarchar(10),ISNULL(@Old_Dispatch_By_Emp_ID,'')) 
							+ ' # Comments : ' + ISNULL(@Old_Comments,'') 
							+ ' # New Value # Uni_Apr_Id : ' + convert(nvarchar(10),ISNULL(@Uni_Apr_Id,''))
							+ ' # Uni_Req_App_Detail_Id : ' + convert(nvarchar(10),ISNULL(@Uni_Req_App_Detail_Id,''))  
							+ ' # Uni_Disp_Id : ' + convert(nvarchar(10),ISNULL(@Uni_Disp_Id,'')) 
							+ ' # Cmp Id : ' + convert(nvarchar(10),ISNULL(@CMP_ID,'')) 
							+ ' # Emp Id : ' + convert(nvarchar(10),ISNULL(@Emp_ID,'')) +
							+ ' # Dispatch Code : ' + convert(nvarchar(10),ISNULL(@Dispatch_Code,''))
							+ ' # Refund Installment : ' + convert(nvarchar(10),ISNULL(@Refund_Installment,'')) 
							+ ' # Deduction Installment : ' + convert(nvarchar(10),ISNULL(@Deduction_Installment,''))  
							+ ' # Refund Start Date: '  +  CASE ISNULL(@Refund_Start_Date,'') WHEN '' THEN '' ELSE convert(nvarchar(21),@Refund_Start_Date) END 
							+ ' # Deduction Start Date : ' +  CASE ISNULL(@Deduction_Start_Date,'') WHEN '' THEN '' ELSE convert(nvarchar(21),@Deduction_Start_Date) END 
							+ ' # System Date : ' + CASE ISNULL(CONVERT(Date, CONVERT(VARCHAR(10), getdate(), 111)),'') WHEN '' THEN '' ELSE convert(nvarchar(21),CONVERT(Date, CONVERT(VARCHAR(10), getdate(), 111))) END 
							--+ ' # Dispatch By Emp ID : ' + convert(nvarchar(10),ISNULL(@Dispatch_By_Emp_ID,'')) 
							+ ' # Comments : ' + ISNULL(@Comments,'')
					
			
		   DELETE FROM T0110_UNIFORM_DISPATCH_DETAIL Where  Uni_Disp_Id = @Uni_Disp_Id
				
		   EXEC P9999_Audit_Trail @Cmp_ID,@TranType,'Uniform Requestition Dispatch',@OldValue,@Emp_ID,@User_Id,@IP_Address,1
			
		END  
 RETURN
