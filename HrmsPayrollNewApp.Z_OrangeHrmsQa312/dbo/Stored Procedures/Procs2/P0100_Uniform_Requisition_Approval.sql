CREATE PROCEDURE [dbo].[P0100_Uniform_Requisition_Approval]
    @Uni_Apr_Id numeric(18, 0)	OutPut,
    @Uni_Req_App_Id	numeric(18, 0)	,
	@Uni_Req_App_Detail_Id	numeric(18, 0)	,
	@CMP_ID	numeric(18, 0)	,
	@Emp_ID	numeric(18, 0)	,
	@Uni_Pieces	numeric(18,0),
    @Uni_Fabric_Price numeric(18,2),
	@Uni_Stitching_Price numeric(18,2),
	@Uni_Amount numeric(18,2),
	@Approval_Code	numeric(18, 0)	,
	@Approval_Date	datetime	,
	@Status	varchar(35)	,
	@Approved_By_Emp_ID	numeric(18, 0)	,
	@Comments nvarchar(250),
	@TranType Varchar(1),
	@User_Id numeric(18, 0),
	@IP_Address nvarchar(50)
	
AS  
	SET NOCOUNT ON   
	DECLARE @Uni_Id numeric(18, 0)
	DECLARE @No_Of_Stock numeric(18, 0)
    DECLARE @Old_Uni_Apr_Id numeric(18, 0)
	DECLARE @Old_Uni_Req_App_Id	numeric(18, 0)	
	DECLARE @Old_Uni_Req_App_Detail_Id	numeric(18, 0)	
	DECLARE @Old_CMP_ID	numeric(18, 0)	
	DECLARE @Old_Emp_ID	numeric(18, 0)	
	DECLARE @Old_Approval_Code	numeric(18, 0)	
	DECLARE @Old_Approval_Date	datetime	
	DECLARE @Old_Status	varchar(35)	
	DECLARE @Old_Approved_By_Emp_ID	numeric(18, 0)	
	DECLARE @Old_Comments	nvarchar(250)	
	DECLARE @Old_Systemdate	nvarchar(250)	
	DECLARE @OldValue nvarchar(max)
	DECLARE @Old_Uni_Pieces	numeric(18,0)
	DECLARE @Old_Uni_Fabric_Price numeric(18,2)
	DECLARE @Old_Uni_Stitching_Price numeric(18,2)
	DECLARE @Old_Uni_Amount numeric(18,2)
		

	SET @Old_Uni_Apr_Id=0
	SET @Old_Uni_Req_App_Id = 0
	SET @Old_Uni_Req_App_Detail_Id  = 0
	SET @Old_CMP_ID  = 0	
	SET @Old_Emp_ID  = 0
	SET @Old_Approval_Code  = 0
	SET @Old_Approval_Date  = null
	SET @Old_Status  = ''
	SET @Old_Approved_By_Emp_ID  = 0
	SET @Old_Systemdate=null
    SET @Old_Comments=''
    SET @Old_Uni_Pieces=0
    SET @Old_Uni_Fabric_Price=0
    SET @Old_Uni_Stitching_Price=0
    SET @Old_Uni_Amount=0
    
	IF @Uni_Req_App_Id =0  
		SET @Uni_Req_App_Id = null  
     
	IF @Uni_Req_App_Detail_Id = 0   
		SET @Uni_Req_App_Detail_Id =null  
		
		Set @No_Of_Stock=0

		
	IF @Approved_By_Emp_ID=0
		SET @Approved_By_Emp_ID=null

		IF @TranType  = 'I'  
		BEGIN 
			IF EXISTS(SELECT 1 
					  FROM T0100_UNIFORM_REQUISITION_APPROVAL WITH (NOLOCK) 
					  WHERE Uni_Req_App_Detail_Id=@Uni_Req_App_Detail_Id 
						    AND Emp_ID=@EMP_ID and CMP_ID=@Cmp_ID) 
				BEGIN
				   SELECT @Uni_Apr_Id=Uni_Apr_Id 
				   FROM T0100_UNIFORM_REQUISITION_APPROVAL WITH (NOLOCK) 
				   WHERE Uni_Req_App_Detail_Id=@Uni_Req_App_Detail_Id AND Emp_ID=@EMP_ID
						 AND CMP_ID=@Cmp_ID
				   RETURN	
						
				END 

			Select @Uni_Id=Uni_Id from T0090_Uniform_Requisition_Application WITH (NOLOCK) where Uni_Req_App_Id= @Uni_Req_App_Id
			Select @No_Of_Stock=isnull(T.Stock_Balance,0) from T0140_Uniform_Stock_Transaction T WITH (NOLOCK) INNER JOIN (select MAX(For_Date) For_Date,Uni_ID from T0140_Uniform_Stock_Transaction WITH (NOLOCK) where(For_Date <= GETDATE() and Cmp_ID=@CMP_ID) group by Uni_ID) Qry on T.For_Date = Qry.For_Date and T.Uni_ID = Qry.Uni_ID inner join T0040_Uniform_Master U WITH (NOLOCK) on T.Uni_ID = U.Uni_ID and T.Cmp_ID = U.Cmp_Id where T.Cmp_ID = @CMP_ID and T.Uni_ID=@Uni_Id
			
			IF @No_Of_Stock  < @Uni_Pieces 
			Begin
			
					Raiserror('@@Uniform Pieces must be less than or equal to current stock.@@',16,2)
					Return -1
			End

			INSERT INTO T0100_UNIFORM_REQUISITION_APPROVAL  
				  (Uni_Req_App_Id,Uni_Req_App_Detail_Id,CMP_ID,Emp_ID,Approval_Code,Approval_Date,Approve_Status,Approved_By_Emp_ID,System_Datetime,Comments,Uni_Pieces,Uni_Fabric_Price,Uni_Stitching_Price,Uni_Amount,Ip_Address)                
			VALUES (@Uni_Req_App_Id,@Uni_Req_App_Detail_Id,@CMP_ID,@Emp_ID,@Approval_Code,CONVERT(Date, CONVERT(VARCHAR(10), @Approval_Date, 111)),@Status,@Approved_By_Emp_ID,CONVERT(Date, CONVERT(VARCHAR(10), getdate(), 111)),@Comments,@Uni_Pieces,@Uni_Fabric_Price,@Uni_Stitching_Price,@Uni_Amount,@IP_Address)   
		
		SET @OldValue =' New Value # Uni_Apr_Id : ' + convert(nvarchar(10),ISNULL(@Uni_Apr_Id,0))
						+ '# Uni_Req_App_Detail_Id : ' + convert(nvarchar(10),ISNULL(@Uni_Req_App_Detail_Id,0))  
						+ '# Cmp Id : ' + convert(nvarchar(10),ISNULL(@CMP_ID,0)) 
						+ '# Emp Id : ' + convert(nvarchar(10),ISNULL(@Emp_ID,0)) +
						+ '# Approval Code : ' + convert(nvarchar(10),ISNULL(@Approval_Code,0)) 
						+ '# Approval Date: '  +  CASE ISNULL(@Approval_Date,'') WHEN '' THEN '' ELSE convert(nvarchar(21),@Approval_Date) END 
						+ '# Status : ' + ISNULL(@Status,'') 
						+ '# System Date : ' + CASE ISNULL(CONVERT(Date, CONVERT(VARCHAR(10), getdate(), 111)),'') WHEN '' THEN '' ELSE convert(nvarchar(21),CONVERT(Date, CONVERT(VARCHAR(10), getdate(), 111))) END 
						+ '# Approved By Emp ID : ' + convert(nvarchar(10),ISNULL(@Approved_By_Emp_ID,0)) 
						+ '# Comments : ' + ISNULL(@Comments,'')
						+ '#' + 'Uni_Pieces :' +  CAST(ISNULL(@Uni_Pieces,0) AS VARCHAR(18))      
						+ '#' + 'Uni_Fabric_Price :' +  CAST(ISNULL(@Uni_Fabric_Price,0) AS VARCHAR(18))      
						+ '#' + 'Uni_Stitching_Price :' +  CAST(ISNULL(@Uni_Stitching_Price,0) AS VARCHAR(18))      
						+ '#' + 'Uni_Amount :' +  CAST(ISNULL(@Uni_Amount,0) AS VARCHAR(18))
						
		EXEC P9999_Audit_Trail @Cmp_ID,@TranType,'Uniform Requestition Approval',@OldValue,@Emp_ID,@User_Id,@IP_Address,1
	
		END  
	ELSE IF @TranType = 'U'  
		BEGIN  

			Select @Uni_Id=Uni_Id from T0090_Uniform_Requisition_Application WITH (NOLOCK) where Uni_Req_App_Id= @Uni_Req_App_Id
			Select @No_Of_Stock=isnull(T.Stock_Balance,0) from T0140_Uniform_Stock_Transaction T WITH (NOLOCK) INNER JOIN (select MAX(For_Date) For_Date,Uni_ID from T0140_Uniform_Stock_Transaction WITH (NOLOCK) where(For_Date <= GETDATE() and Cmp_ID=@CMP_ID) group by Uni_ID) Qry on T.For_Date = Qry.For_Date and T.Uni_ID = Qry.Uni_ID inner join T0040_Uniform_Master U WITH (NOLOCK) on T.Uni_ID = U.Uni_ID and T.Cmp_ID = U.Cmp_Id where T.Cmp_ID = @CMP_ID and T.Uni_ID=@Uni_Id
			
			IF @No_Of_Stock  < @Uni_Pieces 
			Begin
			
					Raiserror('@@Uniform Pieces must be less than or equal to current stock.@@',16,2)
					Return -1
			End


			SELECT  @Old_Uni_Apr_Id=Uni_Req_App_Id,
					@Old_Uni_Req_App_Detail_Id=Uni_Req_App_Detail_Id,
					@Old_CMP_ID=CMP_ID,
					@Old_Emp_ID=Emp_ID,
					@Old_Approval_Code=Approval_Code,
					@Old_Approval_Date=Approval_Date,
					@Old_Status=Approve_Status,
					@Old_Approved_By_Emp_ID=Approved_By_Emp_ID,
					@Old_Systemdate=System_Datetime,
					@Old_Comments =Comments,
					@Old_Uni_Pieces=Uni_Pieces,
					@Old_Uni_Fabric_Price=Uni_Fabric_Price,
					@Old_Uni_Stitching_Price=Uni_Stitching_Price,
					@Old_Uni_Amount=Uni_Amount			
			FROM T0100_UNIFORM_REQUISITION_APPROVAL WITH (NOLOCK) 
			WHERE  Uni_Apr_Id = @Uni_Apr_Id
				
			SET @OldValue = ' old Value # Uni_Apr_Id : ' + convert(nvarchar(10),ISNULL(@Old_Uni_Apr_Id,0))
							+ ' # Uni_Req_App_Detail_Id : ' + convert(nvarchar(10),ISNULL(@Old_Uni_Req_App_Detail_Id,0))  
							+ ' # Cmp Id : ' + convert(nvarchar(10),ISNULL(@Old_CMP_ID,0)) 
							+ ' # Emp Id : ' + convert(nvarchar(10),ISNULL(@Old_Emp_ID,0)) +
							+ ' # Approv al Code : ' + convert(nvarchar(10),ISNULL(@Old_Approval_Code,0)) 
							+ ' # Approval Date: '  +  CASE ISNULL(@Old_Approval_Date,'') WHEN '' THEN '' ELSE convert(nvarchar(21),@Old_Approval_Date) END 
							+ ' # Status : ' + ISNULL(@Old_Status,'') 
							+ ' # System Date : ' + CASE ISNULL(@Old_Systemdate,'') WHEN '' THEN '' ELSE convert(nvarchar(21),@Old_Systemdate) END 
							+ ' # Approved By Emp ID : ' + convert(nvarchar(10),ISNULL(@Old_Approved_By_Emp_ID,0)) 
							+ ' # Comments : ' + ISNULL(@Old_Comments,'') 
							+ ' #' + 'Uni_Pieces :' +  CAST(ISNULL(@Old_Uni_Pieces,0) AS VARCHAR(18))      
							+ ' #' + 'Uni_Fabric_Price :' +  CAST(ISNULL(@Old_Uni_Fabric_Price,0) AS VARCHAR(18))      
							+ ' #' + 'Uni_Stitching_Price :' +  CAST(ISNULL(@Old_Uni_Stitching_Price,0) AS VARCHAR(18))      
							+ ' #' + 'Uni_Amount :' +  CAST(ISNULL(@Old_Uni_Amount,0) AS VARCHAR(18))
							+ ' New Value # Uni_Apr_Id : ' + convert(nvarchar(10),ISNULL(@Uni_Apr_Id,0))
							+ ' # Uni_Req_App_Detail_Id : ' + convert(nvarchar(10),ISNULL(@Uni_Req_App_Detail_Id,0))  
							+ ' # Cmp Id : ' + convert(nvarchar(10),ISNULL(@CMP_ID,0)) 
							+ ' # Emp Id : ' + convert(nvarchar(10),ISNULL(@Emp_ID,0)) +
							+ ' # Approval Code : ' + convert(nvarchar(10),ISNULL(@Approval_Code,0)) 
							+ ' # Approval Date: '  +  CASE ISNULL(@Approval_Date,'') WHEN '' THEN '' ELSE convert(nvarchar(21),@Approval_Date) END 
							+ ' # Status : ' + ISNULL(@Status,'') 
							+ ' # System Date : ' + CASE ISNULL(CONVERT(Date, CONVERT(VARCHAR(10), getdate(), 111)),'') WHEN '' THEN '' ELSE convert(nvarchar(21),CONVERT(Date, CONVERT(VARCHAR(10), getdate(), 111))) END 
							+ ' # Approved By Emp ID : ' + convert(nvarchar(10),ISNULL(@Approved_By_Emp_ID,0)) 
							+ ' # Comments : ' + ISNULL(@Comments,'')
							+ ' #' + 'Uni_Pieces :' +  CAST(ISNULL(@Uni_Pieces,0) AS VARCHAR(18))      
							+ ' #' + 'Uni_Fabric_Price :' +  CAST(ISNULL(@Uni_Fabric_Price,0) AS VARCHAR(18))      
							+ ' #' + 'Uni_Stitching_Price :' +  CAST(ISNULL(@Uni_Stitching_Price,0) AS VARCHAR(18))      
							+ ' #' + 'Uni_Amount :' +  CAST(ISNULL(@Uni_Amount,0) AS VARCHAR(18))	
					
			UPDATE  T0100_UNIFORM_REQUISITION_APPROVAL  
			SET		Uni_Req_App_Id=@Uni_Req_App_Id,
					Uni_Req_App_Detail_Id=@Uni_Req_App_Detail_Id,
					CMP_ID=@CMP_ID,
					Emp_ID=@Emp_ID,
					Approval_Code=@Approval_Code,
					Approval_Date=@Approval_Date,
					Approve_Status=@Status,
					Approved_By_Emp_ID=@Approved_By_Emp_ID,
					System_Datetime=CONVERT(Date, CONVERT(VARCHAR(10), getdate(), 111)),
					Comments =@Comments,
					Uni_Pieces=@Uni_Pieces,
					Uni_Fabric_Price=@Uni_Fabric_Price,
					Uni_Stitching_Price=@Uni_Stitching_Price,
					Uni_Amount=@Uni_Amount,
					Ip_Address=@IP_Address
		   WHERE Uni_Apr_Id = @Uni_Apr_Id  
		   
		   EXEC P9999_Audit_Trail @Cmp_ID,@TranType,'Uniform Requestition Approval',@OldValue,@Emp_ID,@User_Id,@IP_Address,1
		   
		END
	ELSE IF @TranType = 'D'
		BEGIN
		
			SELECT  @Old_Uni_Apr_Id=Uni_Req_App_Id,
					@Old_Uni_Req_App_Detail_Id=Uni_Req_App_Detail_Id,
					@Old_CMP_ID=CMP_ID,
					@Old_Emp_ID=Emp_ID,
					@Old_Approval_Code=Approval_Code,
					@Old_Approval_Date=Approval_Date,
					@Old_Status=Approve_Status,
					@Old_Approved_By_Emp_ID=Approved_By_Emp_ID,
					@Old_Systemdate=System_Datetime,
					@Old_Comments =Comments,
					@Old_Uni_Pieces=Uni_Pieces,
					@Old_Uni_Fabric_Price=Uni_Fabric_Price,
					@Old_Uni_Stitching_Price=Uni_Stitching_Price,
					@Old_Uni_Amount=Uni_Amount
			FROM T0100_UNIFORM_REQUISITION_APPROVAL WITH (NOLOCK) 
			WHERE  Uni_Apr_Id = @Uni_Apr_Id
			
					
			SET @OldValue = ' old Value # Uni_Apr_Id : ' + convert(nvarchar(10),ISNULL(@Old_Uni_Apr_Id,0))
							+ ' # Uni_Req_App_Detail_Id : ' + convert(nvarchar(10),ISNULL(@Old_Uni_Req_App_Detail_Id,0))  
							+ ' # Cmp Id : ' + convert(nvarchar(10),ISNULL(@Old_CMP_ID,0)) 
							+ ' # Emp Id : ' + convert(nvarchar(10),ISNULL(@Old_Emp_ID,0)) +
							+ ' # Approval Code : ' + convert(nvarchar(10),ISNULL(@Old_Approval_Code,0)) 
							+ ' # Approval Date: '  +  CASE ISNULL(@Old_Approval_Date,'') WHEN '' THEN '' ELSE convert(nvarchar(21),@Old_Approval_Date) END 
							+ ' # Status : ' + ISNULL(@Old_Status,'') 
							+ ' # System Date : ' + CASE ISNULL(@Old_Systemdate,'') WHEN '' THEN '' ELSE convert(nvarchar(21),@Old_Systemdate) END 
							+ ' # Approved By Emp ID : ' + convert(nvarchar(10),ISNULL(@Old_Approved_By_Emp_ID,0)) 
							+ ' # Comments : ' + ISNULL(@Old_Comments,'') 
							+ ' New Value # Uni_Apr_Id : ' + convert(nvarchar(10),ISNULL(@Uni_Apr_Id,0))
							+ ' # Uni_Req_App_Detail_Id : ' + convert(nvarchar(10),ISNULL(@Uni_Req_App_Detail_Id,0))  
							+ ' # Cmp Id : ' + convert(nvarchar(10),ISNULL(@CMP_ID,0)) 
							+ ' # Emp Id : ' + convert(nvarchar(10),ISNULL(@Emp_ID,0)) +
							+ ' # Approval Code : ' + convert(nvarchar(10),ISNULL(@Approval_Code,0)) 
							+ ' # Approval Date: '  +  CASE ISNULL(@Approval_Date,'') WHEN '' THEN '' ELSE convert(nvarchar(21),@Approval_Date) END 
							+ ' # Status : ' + ISNULL(@Status,'') 
							+ ' # System Date : ' + CASE ISNULL(CONVERT(Date, CONVERT(VARCHAR(10), getdate(), 111)),'') WHEN '' THEN '' ELSE convert(nvarchar(21),CONVERT(Date, CONVERT(VARCHAR(10), getdate(), 111))) END 
							+ ' # Approved By Emp ID : ' + convert(nvarchar(10),ISNULL(@Approved_By_Emp_ID,0)) 
							+ ' # Comments : ' + ISNULL(@Comments,'')
							+ ' #' + 'Uni_Pieces :' +  CAST(ISNULL(@Old_Uni_Pieces,0) AS VARCHAR(18))      
							+ ' #' + 'Uni_Fabric_Price :' +  CAST(ISNULL(@Old_Uni_Fabric_Price,0) AS VARCHAR(18))      
							+ ' #' + 'Uni_Stitching_Price :' +  CAST(ISNULL(@Old_Uni_Stitching_Price,0) AS VARCHAR(18))      
							+ ' #' + 'Uni_Amount :' +  CAST(ISNULL(@Old_Uni_Amount,0) AS VARCHAR(18))
							
			DELETE 
			FROM T0100_UNIFORM_REQUISITION_APPROVAL 
			WHERE Uni_Apr_Id = @Uni_Apr_Id  
						
		    EXEC P9999_Audit_Trail @Cmp_ID,@TranType,'Uniform Requestition Approval',@OldValue,@Emp_ID,@User_Id,@IP_Address,1
			
		END  
 RETURN
