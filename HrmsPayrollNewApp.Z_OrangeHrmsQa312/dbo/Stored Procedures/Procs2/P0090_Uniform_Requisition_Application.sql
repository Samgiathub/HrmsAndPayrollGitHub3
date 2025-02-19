CREATE PROCEDURE [dbo].[P0090_Uniform_Requisition_Application] 
	@Uni_Req_App_Id Numeric(18,0) output,
	@Cmp_ID	Numeric(18,0),	
	@Uni_ID	Numeric(18,0),	
	@Uni_Req_App_Code	Numeric(18,0),	
	@Request_Date	datetime,	
	@Requested_By_Emp_ID	int,	
	--@System_Date	datetime,	
	@Trantype varchar(1)='',
	@User_Id NUMERIC(18,0) = 0,			
    @IP_Address VARCHAR(30)= ''
		
	AS
BEGIN
	
	SET NOCOUNT ON;
	
	DECLARE @OldValue AS  VARCHAR(MAX)
	DECLARE @OldUni_Req_App_Id varchar(18)
	DECLARE @OldCmp_ID	varchar(18)	
	DECLARE @OldUni_ID	varchar(18)	
	DECLARE @OldUni_Req_App_Code	varchar(18)	
	DECLARE @OldRequest_Date	varchar(18)	
	DECLARE @OldRequested_By_Emp_ID	varchar(18)	
	DECLARE @OldSystem_Date varchar(18)
	
	DECLARE @GUID AS  VARCHAR(1)
    DECLARE @Error_Msg AS VARCHAR(100)
	SET @GUID=''

	SET @OldValue = ''
	SET @OldUni_Req_App_Id =''
	SET @OldCmp_ID = ''
	SET @OldUni_ID =''
	SET @OldUni_Req_App_Code=''
	SET @OldRequested_By_Emp_ID=''
	SET @OldRequest_Date=''
	SET @OldSystem_Date=''
	
	IF @Requested_By_Emp_ID=0
    BEGIN
		SET @Requested_By_Emp_ID=Null
    END


	IF @Trantype = 'I'
		BEGIN		
			--IF EXISTS(SELECT 1 From T0090_UNIFORM_REQUISITION_APPLICATION WITH (NOLOCK)
			--		  WHERE  Request_Date = @Request_Date and Uni_ID = @Uni_ID)
			--	BEGIN
			--		SET @Uni_Req_App_Id = 0
			--		RAISERROR ('@@Record Already Exist.@@', 16, 2)
			--		RETURN
			--	END
				 
			INSERT INTO T0090_UNIFORM_REQUISITION_APPLICATION
				  (Uni_Id,Cmp_ID,Uni_Req_App_Code,Request_Date,Requested_By_Emp_ID,System_Date,Ip_Address)
			VALUES(@Uni_ID,@Cmp_ID,@Uni_Req_App_Code,CONVERT(Date, CONVERT(VARCHAR(10), @Request_Date, 111)),@Requested_By_Emp_ID,CONVERT(Date, CONVERT(VARCHAR(10), Getdate(), 111)) ,@IP_Address)
			
			SET @Uni_Req_App_Id=scope_identity()
			SET @OldValue = 'old Value' +  '#'
							+ 'New Value' + '#'
							+ 'Cmp_ID :' + CAST(ISNULL(@Cmp_ID,'') AS VARCHAR(18))
							+ '#'+ 'Uni_Id :'+ CAST(ISNULL(@Uni_ID,'') AS VARCHAR(18)) + '#'
							+ 'Uni_Req_App_Code :' +CAST(ISNULL(@Uni_Req_App_Code,'') AS VARCHAR(18))    
							+ '#Requested_By_Emp_ID :' +  CAST(ISNULL(@Requested_By_Emp_ID,0) AS VARCHAR(18))      
						    + 'System_Date :' + CAST(ISNULL(Getdate(),0) AS VARCHAR(18))
					   
			EXEC P9999_Audit_Trail @Cmp_ID,@Trantype,'Unifrom Requisition detail',@OldValue,@Uni_Req_App_Id,@User_Id,@IP_Address
  
		            
		END
		ELSE IF @Trantype = 'U'
		BEGIN
		
			SELECT 	@OldCmp_ID=CAST(ISNULL(Cmp_ID,'') AS VARCHAR(18)) ,
					@OldUni_ID=CAST(ISNULL(Uni_ID,'') AS VARCHAR(18)),
					@OldUni_Req_App_Code=CAST(ISNULL(Uni_Req_App_Code,'') AS VARCHAR(18)),
					@OldRequested_By_Emp_ID=CAST(ISNULL(Requested_By_Emp_ID,0) AS VARCHAR(18)),
					@OldSystem_Date=CAST(ISNULL(System_Date,'') AS VARCHAR(18))
			FROM T0090_UNIFORM_REQUISITION_APPLICATION WITH (NOLOCK)
			WHERE Uni_Req_App_Id = @Uni_Req_App_Id
			
			
			UPDATE T0090_UNIFORM_REQUISITION_APPLICATION
			SET Cmp_ID=@Cmp_ID,Uni_ID=@Uni_ID,
				Uni_Req_App_Code=@Uni_Req_App_Code,
				Requested_By_Emp_ID=@Requested_By_Emp_ID,
				System_Date=GETDATE(),
				Ip_Address=@IP_Address
			WHERE Uni_Req_App_Id = @Uni_Req_App_Id
			
			
			SET @OldValue = 'old Value' +  '#'
							+'Cmp_ID :' + CAST(ISNULL(@OldCmp_ID,'') AS VARCHAR(18))
							+ '#Uni_Id :'+CAST(ISNULL(@OldUni_ID,'') AS VARCHAR(18)) 
							+ '#Uni_Req_App_Code :' +CAST(ISNULL(@OldUni_Req_App_Code,'') AS VARCHAR(18))    
							+ '#Requested_By_Emp_ID :' +  CAST(ISNULL(@OldRequested_By_Emp_ID,0) AS VARCHAR(18))      
							+ '#System_Date :' + CAST(ISNULL(@OldSystem_Date,0) AS VARCHAR(18))
							+ 'New Value' 
							+ '#Cmp_ID :' + CAST(ISNULL(@Cmp_ID,'') AS VARCHAR(18))
							+ '#Uni_Id :' +CAST(ISNULL(@Uni_ID,'') AS VARCHAR(18))  
							+ '#Uni_Req_App_Code :' +CAST(ISNULL(@Uni_Req_App_Code,'') AS VARCHAR(18))     
						    + '#Requested_By_Emp_ID :' +  CAST(ISNULL(@Requested_By_Emp_ID,0) AS VARCHAR(18))      
							+ '#System_Date :' + CAST(ISNULL(Getdate(),0) AS VARCHAR(18))
			EXEC P9999_Audit_Trail @Cmp_ID,@Trantype,'Unifrom Requisition detail',@OldValue,@Uni_Req_App_Id,@User_Id,@IP_Address
	    
		END
END
