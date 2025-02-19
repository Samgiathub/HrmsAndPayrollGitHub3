CREATE PROCEDURE [dbo].[P0095_Uniform_Requisition_Application_Detail]
		 @Uni_Req_App_Detail_Id numeric(18,0)output
		,@Uni_Req_App_Id numeric(18,0) 
		,@Cmp_Id numeric(18,0)
		,@Emp_ID numeric(18,0)
		,@Uni_Pieces	numeric(18,0)
		,@Uni_Fabric_Price numeric(18,2)
		,@Uni_Stitching_Price numeric(18,2)
		,@Uni_Amount numeric(18,2)
		,@Trantype char(1)
		,@User_Id NUMERIC(18,0) = 0			
		,@IP_Address VARCHAR(30)= ''
		,@Comments NVARCHAR(250)=''
		
AS
	SET NOCOUNT ON 
	DECLARE @OldValue AS  VARCHAR(MAX)
	DECLARE @OldUni_Req_App_Id Varchar(18) 
	DECLARE @OldCmp_Id Varchar(18)
	DECLARE @OldEmp_ID Varchar(18)
    DECLARE @OldUni_Pieces	Varchar(18)
	DECLARE @OldUni_Fabric_Price Varchar(18)
	DECLARE @OldUni_Stitching_Price Varchar(18)
    DECLARE @OldUni_Amount Varchar(18)
	DECLARE @OldComments NVarchar(250)
			
	
	DECLARE @GUID AS  VARCHAR(1)
    DECLARE @Error_Msg AS VARCHAR(100)
	SET @GUID=''

	SET @OldValue = ''
	
	IF @Trantype ='I'     
		BEGIN   
			INSERT INTO T0095_UNIFORM_REQUISITION_APPLICATION_DETAIL    
				   (Uni_Req_App_Id,Cmp_Id,Emp_ID ,Uni_Pieces,Uni_Fabric_Price ,Uni_Stitching_Price ,Uni_Amount,Comments )
			VALUES (@Uni_Req_App_Id,@Cmp_Id,@Emp_ID ,@Uni_Pieces,@Uni_Fabric_Price ,@Uni_Stitching_Price ,@Uni_Amount,@Comments )

		SET @Uni_Req_App_Detail_Id=SCOPE_IDENTITY()
		
		SET @OldValue = 'new Value' 
						+ '#'+ 'Uni_Req_App_Id :' + CAST(ISNULL(@Uni_Req_App_Id,0) AS VARCHAR(18))
						+ '#'+ 'Cmp_Id :' +CAST(ISNULL(@Cmp_Id,0) AS VARCHAR(18)) 
						+ '#'  + '@Emp_ID :' +CAST(ISNULL(@Emp_ID,0) AS VARCHAR(18))  
						+ '#' + 'Uni_Pieces :' +  CAST(ISNULL(@Uni_Pieces,0) AS VARCHAR(18))      
						+ '#' + 'Uni_Fabric_Price :' +  CAST(ISNULL(@Uni_Fabric_Price,0) AS VARCHAR(18))      
						+ '#' + 'Uni_Stitching_Price :' +  CAST(ISNULL(@Uni_Stitching_Price,0) AS VARCHAR(18))      
						+ '#' + 'Uni_Amount :' +  CAST(ISNULL(@Uni_Amount,0) AS VARCHAR(18))      
						+ '#' + 'Comments :' +  CAST(ISNULL(@Comments,'') AS VARCHAR(250))
				   
		END  
	ELSE IF @Trantype ='U'     
		BEGIN   
			SELECT  @OldUni_Req_App_Id =Uni_Req_App_Id, 
						@OldCmp_Id =Cmp_Id,
	 					@OldEmp_ID =Emp_ID,
					    @OldUni_Pieces=Uni_Pieces,
						@OldUni_Fabric_Price=Uni_Fabric_Price,
						@OldUni_Stitching_Price=Uni_Stitching_Price,
						@OldUni_Amount =Uni_Amount	,
						@OldComments=Comments			
			FROM T0095_UNIFORM_REQUISITION_APPLICATION_DETAIL WITH (NOLOCK)
		    WHERE Uni_Req_App_Detail_Id=@Uni_Req_App_Detail_Id
				 
			Update T0095_UNIFORM_REQUISITION_APPLICATION_DETAIL
			SET Uni_Req_App_Id=@Uni_Req_App_Id,
				Cmp_Id=@Cmp_Id,
				Emp_ID=@Emp_ID ,
				Uni_Pieces=@Uni_Pieces,
				Uni_Fabric_Price =@Uni_Fabric_Price,
				Uni_Stitching_Price=@Uni_Stitching_Price ,
				Uni_Amount=@Uni_Amount
			WHERE Uni_Req_App_Detail_Id=@Uni_Req_App_Detail_Id
				 
			SET @OldValue ='Old Value' 
							+ '#'+ 'Uni_Req_App_Id :' + CAST(ISNULL(@OldUni_Req_App_Id,0) AS VARCHAR(18))
							+ '#'+ 'Cmp_Id :' +CAST(ISNULL(@OldCmp_Id,0) AS VARCHAR(18)) 
							+ '#'  + '@Emp_ID :' +CAST(ISNULL(@OldEmp_ID,0) AS VARCHAR(18))  
							+ '#' + 'Uni_Pieces :' +  CAST(ISNULL(@OldUni_Pieces,0) AS VARCHAR(18))      
							+ '#' + 'Uni_Fabric_Price :' +  CAST(ISNULL(@OldUni_Fabric_Price,0) AS VARCHAR(18))      
							+ '#' + 'Uni_Stitching_Price :' +  CAST(ISNULL(@OldUni_Stitching_Price,0) AS VARCHAR(18))      
							+ '#' + 'Uni_Amount :' +  CAST(ISNULL(@OldUni_Amount,0) AS VARCHAR(18))   
							+ '#' + 'Comments :' +  CAST(ISNULL(@OldComments,0) AS VARCHAR(250))
							+ '#'+ 'new Value' 
							+ '#'+ 'Uni_Req_App_Id :' + CAST(ISNULL(@Uni_Req_App_Id,0) AS VARCHAR(18))
							+ '#'+	'#Cmp_Id :' +CAST(ISNULL(@Cmp_Id,0) AS VARCHAR(18)) 
							+ '#'  + '@Emp_ID :' +CAST(ISNULL(@Emp_ID,0) AS VARCHAR(18))  
							+ '#' + 'Uni_Pieces :' +  CAST(ISNULL(@Uni_Pieces,0) AS VARCHAR(18))      
							+ '#' + 'Uni_Fabric_Price :' +  CAST(ISNULL(@Uni_Fabric_Price,0) AS VARCHAR(18))      
							+ '#' + 'Uni_Stitching_Price :' +  CAST(ISNULL(@Uni_Stitching_Price,0) AS VARCHAR(18))      
							+ '#' + 'Uni_Amount :' +  CAST(ISNULL(@Uni_Amount,0) AS VARCHAR(18))      
							+ '#' + 'Comments :' +  CAST(ISNULL(@Comments,0) AS VARCHAR(250))    	   
									
				
		END  
	ELSE IF @Trantype ='D'    
		BEGIN    
			 SELECT  @OldUni_Req_App_Id =Uni_Req_App_Id, 
						@OldCmp_Id =Cmp_Id,
	 					@OldEmp_ID =Emp_ID,
					    @OldUni_Pieces=Uni_Pieces,
						@OldUni_Fabric_Price=Uni_Fabric_Price,
						@OldUni_Stitching_Price=Uni_Stitching_Price,
						@OldUni_Amount =Uni_Amount	,
						@OldComments=Comments			
			 FROM T0095_UNIFORM_REQUISITION_APPLICATION_DETAIL WITH (NOLOCK)
			 WHERE Uni_Req_App_Detail_Id=@Uni_Req_App_Detail_Id
				
					
			--DELETE 
			--FROM T0095_UNIFORM_REQUISITION_APPLICATION_DETAIL 
			--WHERE Uni_Req_App_Detail_Id = @Uni_Req_App_Detail_Id  
			 
			SET @OldValue ='Old Value' +  '#'+ 'Uni_Req_App_Id :' + CAST(ISNULL(@OldUni_Req_App_Id,0) AS VARCHAR(18))
							+ '#'+'Cmp_Id :' +CAST(ISNULL(@OldCmp_Id,0) AS VARCHAR(18)) + '#'  + '@Emp_ID :' +CAST(ISNULL(@OldEmp_ID,0) AS VARCHAR(18))  
							+ '#' + 'Uni_Pieces :' +  CAST(ISNULL(@OldUni_Pieces,0) AS VARCHAR(18))      
							+ '#' + 'Uni_Fabric_Price :' +  CAST(ISNULL(@OldUni_Fabric_Price,0) AS VARCHAR(18))      
							+ '#' + 'Uni_Stitching_Price :' +  CAST(ISNULL(@OldUni_Stitching_Price,0) AS VARCHAR(18))      
							+ '#' + 'Uni_Amount :' +  CAST(ISNULL(@OldUni_Amount,0) AS VARCHAR(18))      
							+ '#' + 'Comments :' +  CAST(ISNULL(@OldComments,0) AS VARCHAR(250))    	   
							+'#'+ 'new Value' +  '#'
				
					IF  EXISTS(SELECT 1 
						  FROM T0100_Uniform_Requisition_Approval URA WITH (NOLOCK)
						  WHERE URA.Uni_Req_App_Detail_Id = @Uni_Req_App_Detail_Id 
								AND URA.Uni_Req_App_Id=@Uni_Req_App_Id)
				BEGIN
					RAISERROR('@@ Approval Records Can Not Deleted. @@',16,2)
					return
				END
									
					DELETE 
					FROM T0095_UNIFORM_REQUISITION_APPLICATION_DETAIL 
					WHERE Uni_Req_App_Detail_Id = @Uni_Req_App_Detail_Id AND Cmp_ID=@Cmp_ID  

					IF Not Exists (SELECT 1 
								   FROM T0095_UNIFORM_REQUISITION_APPLICATION_DETAIL WITH (NOLOCK) 
								   WHERE Uni_Req_App_Id= @Uni_Req_App_Id AND Cmp_ID=@Cmp_ID)				
					BEGIN
						DELETE 
						FROM T0090_Uniform_Requisition_Application 
						WHERE Uni_Req_App_Id = @Uni_Req_App_Id AND Cmp_ID=@Cmp_ID
					END
			
		END    
   EXEC P9999_Audit_Trail @Cmp_ID,@Trantype,'Unifrom Requisition detail',@OldValue,@Uni_Req_App_Detail_Id,@User_Id,@IP_Address
  