

-- =============================================
-- Author:		Binal
-- Create date: 22-May-2019
-- Description:	Validation For Make Checker
-- =============================================
CREATE PROCEDURE [dbo].[P_VALIDATE_EMP_APP]
	-- Add the parameters for the stored procedure here
	@EMP_TRAN_ID BIGINT,
	@Mode   VARCHAR(50),
	@Is_GroupOFCmp TINYINT =0,
	@Max_Emp_Code VARCHAR(64)='',
	@Emp_Code NUMERIC(18,0)=0,
	 @Alpha_Emp_Code     VARCHAR(50) = ''
 
AS
BEGIN
	
	SET NOCOUNT ON;

	DECLARE @CMP_ID			    INT=0	
	DECLARE @EMP_ID			    INT=0
	DECLARE @EMP_FIRST_NAME	    VARCHAR(50) = ''
	DECLARE @EMP_LAST_NAME		VARCHAR(50) = ''
	DECLARE @DATE_OF_BIRTH		VARCHAR(20) = ''
	DECLARE @PAN_NO			    VARCHAR(10) = ''
	DECLARE @UAN_NO			    VARCHAR(20) = ''
	DECLARE @Aadhar_Card_No		VARCHAR(20) = ''
	DECLARE @SSN_NO             VARCHAR(20) = '' /* FOR PF */
	DECLARE @SIN_NO             VARCHAR(20) = '' /* FOR ESIC */
	DECLARE @Enroll_No          INT=0
	DECLARE @COLUMN_NAME		VARCHAR(20) 
	DECLARE @COLUMN_VALUE		VARCHAR(100)	
    DECLARE @Emp_ApplicationID INT=0
    DECLARE @Validate_Fields    VARCHAR(MAX) = ''   
   
    DECLARE @EXISTING_DETAIL VARCHAR(256)
					  
	IF Exists(SELECT 1 FROM T0060_EMP_MASTER_APP WITH (NOLOCK) WHERE Emp_Tran_ID=@EMP_TRAN_ID)
		IF @Mode='EMP_APP'		
				
				SELECT @CMP_ID=Cmp_ID,@EMP_ID=EMP_ID,@EMP_FIRST_NAME=Emp_First_Name,
					   @EMP_LAST_NAME=Emp_Last_Name,@DATE_OF_BIRTH=Date_Of_Birth,@PAN_NO=Pan_No,@UAN_NO=UAN_No,
					   @Aadhar_Card_No=Aadhar_Card_No,@Enroll_No=Enroll_No,@Emp_ApplicationID=Emp_Application_ID,
					   @SSN_NO=SSN_NO,@SIN_NO=SIN_NO
					   --,
					   --@Alpha_Emp_Code=Alpha_Emp_Code
				From T0060_EMP_MASTER_APP WITH (NOLOCK) WHERE Emp_Tran_ID=@EMP_TRAN_ID
		    
		    
		    	IF ISNULL(@Enroll_No ,0) <> 0
				
					IF EXISTS(SELECT 1 FROM T0080_EMP_MASTER E WITH (NOLOCK)
								INNER JOIN T0060_EMP_MASTER_APP APP WITH (NOLOCK) ON E.Enroll_No=APP.Enroll_No AND E.Emp_ID <> APP.Emp_ID
								 WHERE APP.Emp_Tran_ID=@EMP_TRAN_ID)
						 RAISERROR('@@Enroll No already exist in Employee Master@@', 16,1);
					
					Else IF EXISTS(SELECT 1 FROM T0060_EMP_MASTER_APP E
								WHERE E.Emp_Application_ID <> @Emp_ApplicationID AND E.Enroll_No=@Enroll_No)
						 RAISERROR('@@Enroll No already exist in Employee Application@@', 16,1);
						 
		  			
				IF ISNULL(@Alpha_Emp_Code ,'') <> ''
				BEGIN
					IF @Is_GroupOFCmp = 0	
					BEGIN
							SET @Emp_ID = 0
							IF Exists(select Emp_ID From dbo.T0080_EMP_MASTER WITH (NOLOCK)
			                           WHERE Alpha_Emp_Code = @Alpha_Emp_Code And Cmp_ID 
											In (Select Cmp_ID From T0010_COMPANY_MASTER WITH (NOLOCK) ))
										AND @Max_Emp_Code = 'Group_Company_Wise'
							BEGIN	
						

									SELECT	@EXISTING_DETAIL = Cmp_Name 
									FROM	T0080_EMP_MASTER E WITH (NOLOCK)
											INNER JOIN T0010_COMPANY_MASTER C WITH (NOLOCK) ON e.Cmp_ID=c.Cmp_Id 
									WHERE	EMP_CODE = @Emp_code

									SET @EXISTING_DETAIL = '@@Employee Code already exist in "' + @EXISTING_DETAIL + '" Company.@@'
									SET @Emp_ID = 0

									RAISERROR (@EXISTING_DETAIL , 16, 2)
							
							END
					
					
					END	
					Else If @Is_GroupOFCmp = 1
					BEGIN
							If Exists(select Emp_ID From dbo.T0080_EMP_MASTER WITH (NOLOCK)
							WHERE Alpha_Emp_Code = @Alpha_Emp_Code And Cmp_ID 
							In (Select Cmp_ID From T0010_COMPANY_MASTER WITH (NOLOCK) Where is_GroupOFCmp = 1))
								AND @Max_Emp_Code = 'Group_Company_Wise'
								BEGIN	
								
									SELECT	@EXISTING_DETAIL = Cmp_Name 
									FROM	T0080_EMP_MASTER E WITH (NOLOCK)
											INNER JOIN T0010_COMPANY_MASTER C WITH (NOLOCK) ON e.Cmp_ID=c.Cmp_Id 
									WHERE	EMP_CODE = @Emp_code AND C.is_GroupOFCmp=1

									SET @EXISTING_DETAIL = '@@Employee Code already exist in "' + @EXISTING_DETAIL + '" Company.@@'

								END
							ELSE If Exists(select Emp_ID From dbo.T0080_EMP_MASTER WITH (NOLOCK)
							WHERE (Alpha_Emp_Code = @Alpha_Emp_Code)
								 And Cmp_ID = @Cmp_ID)
								AND @Max_Emp_Code = 'Company_Wise'
								begin									

								 SET @EXISTING_DETAIL = '@@Employee Code already exist in Current Company.@@'

								END
									IF (@EXISTING_DETAIL IS NOT NULL)
								BEGIN
								
									SET @Emp_ID = 0
									RAISERROR (@EXISTING_DETAIL , 16, 2)
									  
								END
					End

					IF EXISTS(SELECT 1 FROM T0060_EMP_MASTER_APP E WITH (NOLOCK)
								WHERE E.Emp_Application_ID <> @Emp_ApplicationID AND E.Alpha_Emp_Code=@Alpha_Emp_Code)
						 RAISERROR('@@Employee Code already exist in Employee Application@@', 16,1);
				End

				
				
				ELSE IF ISNULL(@Aadhar_Card_No ,'') <> ''
				
					IF EXISTS(SELECT 1 FROM T0080_EMP_MASTER E WITH (NOLOCK)
								INNER JOIN T0060_EMP_MASTER_APP APP WITH (NOLOCK) ON E.Aadhar_Card_No=APP.Aadhar_Card_No AND E.Emp_ID <> APP.Emp_ID 
								WHERE APP.Emp_Tran_ID=@EMP_TRAN_ID)
						 RAISERROR('@@AADHAR Card No already exist in Employee Master@@', 16,1);
						 
						 
						 
					Else IF EXISTS(SELECT 1 FROM T0060_EMP_MASTER_APP E WITH (NOLOCK)
								WHERE E.Emp_Application_ID <> @Emp_ApplicationID AND E.Aadhar_Card_No=@Aadhar_Card_No)
						 RAISERROR('@@AADHAR Card No already exist in Employee Application@@', 16,1);
					 
				
			    ELSE IF ISNULL(@UAN_NO ,'') <> ''
					 
					 IF EXISTS(SELECT 1 FROM T0080_EMP_MASTER E WITH (NOLOCK)
								INNER JOIN T0060_EMP_MASTER_APP APP WITH (NOLOCK) ON E.UAN_No=APP.UAN_No AND E.Emp_ID <> APP.Emp_ID 
								WHERE APP.Emp_Tran_ID=@EMP_TRAN_ID)
						 RAISERROR('@@UAN No already exist in Employee Master@@', 16,1);
						 
						 
					Else IF EXISTS(SELECT 1 FROM T0060_EMP_MASTER_APP E WITH (NOLOCK)
								WHERE E.Emp_Application_ID <> @Emp_ApplicationID AND E.UAN_No=@UAN_NO)
						 RAISERROR('@@UAN No already exist in Employee Application@@', 16,1);
					 
			     
				ELSE IF ISNULL(@SSN_NO ,'') <> ''
					
					IF EXISTS(SELECT 1 FROM T0080_EMP_MASTER E WITH (NOLOCK)
								INNER JOIN T0060_EMP_MASTER_APP APP WITH (NOLOCK) ON E.SSN_NO=APP.SSN_NO AND E.Emp_ID <> APP.Emp_ID 
								WHERE APP.Emp_Tran_ID=@EMP_TRAN_ID)
						 RAISERROR('@@PF No already exist in Employee Master@@', 16,1);
						 
						 
					Else IF EXISTS(SELECT 1 FROM T0060_EMP_MASTER_APP E WITH (NOLOCK)
								WHERE E.Emp_Application_ID <> @Emp_ApplicationID AND E.SSN_NO=@SSN_NO)
						 RAISERROR('@@PF No already exist in Employee Application@@', 16,1);
					 
				ELSE IF ISNULL(@PAN_NO ,'') <> ''
					 
					IF EXISTS(SELECT 1 FROM T0080_EMP_MASTER E WITH (NOLOCK)
								INNER JOIN T0060_EMP_MASTER_APP APP ON E.Pan_No=APP.Pan_No AND E.Emp_ID <> APP.Emp_ID 
								WHERE APP.Emp_Tran_ID=@EMP_TRAN_ID)
						 RAISERROR('@@PAN No already exist in Employee Master@@', 16,1);
						 
						 
					Else IF EXISTS(SELECT 1 FROM T0060_EMP_MASTER_APP E WITH (NOLOCK)
								WHERE E.Emp_Application_ID <> @Emp_ApplicationID AND E.Pan_No=@PAN_NO)
						 RAISERROR('@@PAN No already exist in Employee Application@@', 16,1);
									 
				ELSE IF ISNULL(@SIN_NO ,'') <> ''
				
					IF EXISTS(SELECT 1 FROM T0080_EMP_MASTER E WITH (NOLOCK)
								INNER JOIN T0060_EMP_MASTER_APP APP WITH (NOLOCK) ON E.SIN_NO=APP.SIN_NO AND E.Emp_ID <> APP.Emp_ID 
								WHERE APP.Emp_Tran_ID=@EMP_TRAN_ID)
						 RAISERROR('@@ESIC No already exist in Employee Master@@', 16,1);
						 
						 
					Else IF EXISTS(SELECT 1 FROM T0060_EMP_MASTER_APP E WITH (NOLOCK)
								WHERE E.Emp_Application_ID <> @Emp_ApplicationID AND E.SIN_NO=@SIN_NO)
						 RAISERROR('@@ESIC No already exist in Employee Application@@', 16,1);
						 
			    
				--SET @Validate_Fields='UAN::'
				--IF ISNULL(@UAN_NO,'') <>''
				--	SET @Validate_Fields= @Validate_Fields + @UAN_NO
				
				--IF ISNULL(@PAN_NO,'') <>''				
				--	SET @Validate_Fields=@Validate_Fields +',PAN::'+@PAN_NO
				
				--IF ISNULL(@SSN_NO,'') <>''				
				--	SET @Validate_Fields=@Validate_Fields +',PF::'+@SSN_NO
				
				--IF ISNULL(@SIN_NO,'') <>''				
				--	SET @Validate_Fields=@Validate_Fields +',ESIC::'+@SIN_NO
				
				--IF ISNULL(@Aadhar_Card_No,'') <>''				
				--	SET @Validate_Fields=@Validate_Fields +',AADHAR::'+@Aadhar_Card_No
		    
		    --EXEC P_EMP_UAN_PAN_VALIDATION @Cmp_ID=@CMP_ID,@Emp_Tran_ID=@Emp_Tran_ID,@Pan_No='',@Emp_First_Name=@EMP_FIRST_NAME,@Emp_Last_Name=@EMP_LAST_NAME,@Date_Of_Birth=@DATE_OF_BIRTH,@Column_NAME='ALL',@Column_Value=@Validate_Fields
		    	
					 
					 
		END

