

---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P_EMP_UAN_PAN_VALIDATION_APP]
	 @CMP_ID			int
	,@Emp_Tran_ID		bigint  	
	,@EMP_FIRST_NAME	VARCHAR(50) = ''
	,@EMP_LAST_NAME		VARCHAR(50) = ''
	,@DATE_OF_BIRTH		VARCHAR(20) = ''
	,@PAN_NO			VARCHAR(10) = ''
	--,@UAN_NO			VARCHAR(20) = ''
	,@COLUMN_NAME		VARCHAR(20) 
	,@COLUMN_VALUE		VARCHAR(100)
	
	
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
			DECLARE @EMP_LEFT AS VARCHAR = ''
			DECLARE @UANNO	  AS VARCHAR(20)
			DECLARE @PANNO	  AS VARCHAR(10)
			DECLARE @EmpTranID	  AS NUMERIC
			DECLARE @PFNO	  AS VARCHAR(25)
			DECLARE	@ESICNO	  AS VARCHAR(25)
			DECLARE @AADHARNO AS VARCHAR(25)
			DECLARE @EMP_FULL_NAME  AS VARCHAR(MAX) = ''
			
			
			Declare @Emp_Application_Id AS Integer
			SET @Emp_Application_Id= (select Emp_Application_ID from T0060_EMP_MASTER_APP WITH (NOLOCK) where Emp_Tran_ID=@Emp_Tran_ID )
			SET @Emp_Application_Id=isnull(@Emp_Application_Id,0)
			
			
			IF @COLUMN_NAME = 'ALL'
				BEGIN
						
						IF OBJECT_Id('TEMP.DB..#COLUMNS') is not null
							DROP TABLE #COLUMNS

						CREATE TABLE #COLUMNS
						(
							COLUMN_NAME		VARCHAR(50) default '',
							COLUMN_VALUE	VARCHAR(50) default ''
						)

						DECLARE @Emp_Column_Value as VARCHAR(30)
						
						Declare @CUR_COLUMN_VALUE as Varchar(30)



						DECLARE CUR_EMP CURSOR FOR
						select [data] from dbo.split(@COLUMN_VALUE, ',')
						OPEN  CUR_EMP      
							FETCH NEXT FROM CUR_EMP INTO @CUR_COLUMN_VALUE
							WHILE @@FETCH_STATUS = 0      
								BEGIN      
										SET @COLUMN_NAME = SUBSTRING(@CUR_COLUMN_VALUE, 0, CHARINDEX('::',@CUR_COLUMN_VALUE))
										SET @COLUMN_VALUE = SUBSTRING(@CUR_COLUMN_VALUE, CHARINDEX('::',@CUR_COLUMN_VALUE)+2, LEN(@CUR_COLUMN_VALUE))

										

										INsert INto #COLUMNS
										EXEC P_EMP_UAN_PAN_VALIDATION_APP @CMP_ID,@Emp_Tran_ID,@EMP_FIRST_NAME,@EMP_LAST_NAME,@DATE_OF_BIRTH,@PAN_NO,@COLUMN_NAME,@COLUMN_VALUE


							Fetch next FROM CUR_EMP  into @CUR_COLUMN_VALUE
							END      
						close CUR_EMP      
						Deallocate CUR_EMP  

						delete from #COLUMNS where COLUMN_VALUE = ''

						select * from #COLUMNS

				END				
			ELSE IF @COLUMN_NAME = 'UAN' And @COLUMN_VALUE <> '' And @COLUMN_VALUE <> '0'
				BEGIN
			
					SELECT	@UANNO = UAN_NO,@EmpTranID = Emp_Tran_ID,@EMP_LEFT = EMP_LEFT
					FROM	T0060_EMP_MASTER_APP WITH (NOLOCK)
					WHERE	UAN_NO = @COLUMN_VALUE AND 
							Emp_Application_ID <> IsNULL(@Emp_Application_Id,0) 
							
							AND CMP_ID = @CMP_ID 					
					
					IF @EMP_LEFT = 'Y'  AND	@UANNO IS NOT NULL 
						BEGIN
							IF NOT EXISTS(
											SELECT	1 
											FROM	T0060_EMP_MASTER_APP WITH (NOLOCK)
											WHERE	Emp_Application_ID <> IsNULL(@Emp_Application_Id,0)  AND
													PAN_NO = ISNULL(@PAN_NO,PAN_NO) AND 
													DATE_OF_BIRTH = CASE WHEN ISNULL(CONVERT(DATETIME , @DATE_OF_BIRTH , 103),'') = '' THEN DATE_OF_BIRTH
																	ELSE CONVERT(DATETIME , @DATE_OF_BIRTH , 103)  END
													AND	UPPER(EMP_FIRST_NAME) =  UPPER(@EMP_FIRST_NAME) 
													AND	UPPER(EMP_LAST_NAME) = UPPER(@EMP_LAST_NAME)
																						
										  )											
											BEGIN																				
													SELECT	'UAN',@COLUMN_VALUE	AS UAN_NO													
											END
						END
					ELSE
						BEGIN
								IF EXISTS(
											SELECT	1 
											FROM	T0060_EMP_MASTER_APP WITH (NOLOCK)
											WHERE	UAN_NO = @COLUMN_VALUE
													AND CMP_ID = @CMP_ID
													And Emp_Application_ID <> IsNULL(@Emp_Application_Id,0)	
																					
										)											
											BEGIN																							
												SELECT	'UAN',@COLUMN_VALUE	AS UAN_NO													
											END
							END			
						
				END
			-------------------------FOR PAN NO VALIDATION-----------------
			
			ELSE IF @COLUMN_NAME = 'PAN' And @COLUMN_VALUE <> '' And @COLUMN_VALUE <> '0'
				BEGIN
			
					SELECT	@PANNO = PAN_NO,@EmpTranID = Emp_Tran_ID,@EMP_LEFT = EMP_LEFT
					FROM	T0060_EMP_MASTER_APP WITH (NOLOCK)
					WHERE	PAN_NO = @COLUMN_VALUE AND
							Emp_Application_ID <> IsNULL(@Emp_Application_Id,0)
							AND CMP_ID = @CMP_ID 		
																
												
					
					IF @EMP_LEFT = 'Y' AND @PANNO IS NOT NULL
						BEGIN	
							IF NOT EXISTS(
											SELECT	1
											FROM	T0060_EMP_MASTER_APP WITH (NOLOCK)
											WHERE	Emp_Application_ID <> IsNULL(@Emp_Application_Id,0) AND												
													DATE_OF_BIRTH = CASE WHEN ISNULL(CONVERT(DATETIME , @DATE_OF_BIRTH , 103),'') = '' THEN DATE_OF_BIRTH
																	ELSE CONVERT(DATETIME , @DATE_OF_BIRTH , 103)  END   
													AND	UPPER(EMP_FIRST_NAME) =  UPPER(@EMP_FIRST_NAME) 
													AND	UPPER(EMP_LAST_NAME) = UPPER(@EMP_LAST_NAME)
																
																					
											)											
												BEGIN	
														SELECT	'PAN',@COLUMN_VALUE	AS	PAN_NO												
												END
						END										
					ELSE
						BEGIN					 
							IF EXISTS(
										SELECT	1 
										FROM	T0060_EMP_MASTER_APP WITH (NOLOCK)
										WHERE	PAN_NO = @COLUMN_VALUE
												AND CMP_ID = @CMP_ID
												AND Emp_Application_ID <> IsNULL(@Emp_Application_Id,0)
												
																				
									 )											
										BEGIN	
												SELECT	'PAN',@COLUMN_VALUE	AS	PAN_NO													
										END
						END
				END
				
			-------------------------FOR PF NO VALIDATION-----------------
			ELSE IF @COLUMN_NAME = 'PF' And @COLUMN_VALUE <> '' And @COLUMN_VALUE <> '0'
				BEGIN
			
					SELECT	@PFNO = SSN_NO ,@EmpTranID = Emp_Tran_ID,@EMP_LEFT = EMP_LEFT
					FROM	T0060_EMP_MASTER_APP WITH (NOLOCK)
					WHERE	Emp_Application_ID <> IsNULL(@Emp_Application_Id,0)  
							  
							AND
							 CMP_ID = @CMP_ID AND SSN_NO = @COLUMN_VALUE
							  			
					
					
					IF @EMP_LEFT = 'Y' AND @PFNO IS NOT NULL
						BEGIN	
							IF NOT EXISTS(
											SELECT	1
											FROM	T0060_EMP_MASTER_APP WITH (NOLOCK)
											WHERE	Emp_Application_ID <> IsNULL(@Emp_Application_Id,0)  
													--Emp_Tran_ID = @EmpTranID 
													AND																								
													DATE_OF_BIRTH = CASE WHEN ISNULL(CONVERT(DATETIME , @DATE_OF_BIRTH , 103),'') = '' THEN DATE_OF_BIRTH
																	ELSE CONVERT(DATETIME , @DATE_OF_BIRTH , 103)  END   
													AND	UPPER(EMP_FIRST_NAME) =  UPPER(@EMP_FIRST_NAME) 
													AND	UPPER(EMP_LAST_NAME) = UPPER(@EMP_LAST_NAME)
																																					
											)											
												BEGIN
														SELECT	'PF',1	AS	SSN_NO												
												END
						END										
					ELSE
						BEGIN		
						 					
							IF EXISTS(
										SELECT	1 
										FROM	T0060_EMP_MASTER_APP WITH (NOLOCK)
										WHERE	SSN_NO = @COLUMN_VALUE
												AND CMP_ID = @CMP_ID
												AND Emp_Application_ID <> IsNULL(@Emp_Application_Id,0)  
												
																					
									 )											
										BEGIN
										
										
												SELECT	'PF',@COLUMN_VALUE	AS	SSN_NO													
										END
						END
				END
				
				-------------------------FOR ESIC NO VALIDATION-----------------
				ELSE IF @COLUMN_NAME = 'ESIC' And @COLUMN_VALUE <> '' And @COLUMN_VALUE <> '0'
				BEGIN
			
					
								SELECT	@ESICNO = SIN_NO,@EmpTranID = Emp_Tran_ID,@EMP_LEFT = EMP_LEFT
								FROM	T0060_EMP_MASTER_APP WITH (NOLOCK)
								WHERE	SIN_NO = @COLUMN_VALUE 
										AND Emp_Application_ID <> IsNULL(@Emp_Application_Id,0)
										 
										AND CMP_ID = @CMP_ID
													
					
							
					IF @EMP_LEFT = 'Y' AND @ESICNO IS NOT NULL AND @COLUMN_VALUE <> '0'
						BEGIN	
							IF NOT EXISTS(
											SELECT	1
											FROM	T0060_EMP_MASTER_APP WITH (NOLOCK) 
											WHERE	Emp_Application_ID <> IsNULL(@Emp_Application_Id,0) AND
																									
													DATE_OF_BIRTH = CASE WHEN ISNULL(CONVERT(DATETIME , @DATE_OF_BIRTH , 103),'') = '' THEN DATE_OF_BIRTH
																	ELSE CONVERT(DATETIME , @DATE_OF_BIRTH , 103)  END   
													AND	UPPER(EMP_FIRST_NAME) =  UPPER(@EMP_FIRST_NAME) 
													AND	UPPER(EMP_LAST_NAME) = UPPER(@EMP_LAST_NAME)	
																
																			
											)											
												BEGIN
														SELECT	'ESIC',@COLUMN_VALUE	AS	ESIC_NO												
												END
						END										
					ELSE
						BEGIN					 
							IF EXISTS(
										SELECT	1 
										FROM	T0060_EMP_MASTER_APP WITH (NOLOCK)
										WHERE	SIN_NO = @COLUMN_VALUE
												AND CMP_ID = @CMP_ID
												AND Emp_Application_ID <> IsNULL(@Emp_Application_Id,0)
													
												AND @COLUMN_VALUE <> '0'						
															
									 )											
										BEGIN
												SELECT	'ESIC',@COLUMN_VALUE	AS	ESIC_NO													
										END
						END
				END
			-----------------------------AADHAR CARD NO VALIDATION---------------------------
			
			
			ELSE IF @COLUMN_NAME = 'AADHAR' And @COLUMN_VALUE <> '' And @COLUMN_VALUE <> '0'
				BEGIN
			
					SELECT	@AADHARNO = AADHAR_CARD_NO,@EmpTranID = Emp_Tran_ID,@EMP_LEFT = EMP_LEFT
					FROM	T0060_EMP_MASTER_APP WITH (NOLOCK)
					WHERE	AADHAR_CARD_NO = @COLUMN_VALUE AND 
							Emp_Application_ID <> IsNULL(@Emp_Application_Id,0)
							
							AND CMP_ID = @CMP_ID 										
					
					
											
					IF @EMP_LEFT = 'Y' AND @AADHARNO IS NOT NULL	
						BEGIN	
							IF NOT EXISTS(
											SELECT	1
											FROM	T0060_EMP_MASTER_APP  WITH (NOLOCK)
											WHERE	Emp_Application_ID <> IsNULL(@Emp_Application_Id,0)
													
													AND													
													DATE_OF_BIRTH = CASE WHEN ISNULL(CONVERT(DATETIME , @DATE_OF_BIRTH , 103),'') = '' THEN DATE_OF_BIRTH
																	ELSE CONVERT(DATETIME , @DATE_OF_BIRTH , 103)  END   
													AND	UPPER(EMP_FIRST_NAME) =  UPPER(@EMP_FIRST_NAME) 
													AND	UPPER(EMP_LAST_NAME) = UPPER(@EMP_LAST_NAME)
																	
																			
											)											
												BEGIN
														SELECT	'AADHAR',@COLUMN_VALUE	AS	AADHAR_CARD_NO												
												END
						END										
					ELSE
						BEGIN					 
							IF EXISTS(
										SELECT	1 
										FROM	T0060_EMP_MASTER_APP WITH (NOLOCK)
										WHERE	AADHAR_CARD_NO = @COLUMN_VALUE
												AND CMP_ID = @CMP_ID
												AND Emp_Application_ID <> IsNULL(@Emp_Application_Id,0)
												
																					
									 )											
										BEGIN
												SELECT	'AADHAR',@COLUMN_VALUE	AS	AADHAR_CARD_NO													
										END
						END
				END
			-----------------------------END---------------------------
			-----------------------------BANK ACCOUNT NO VALIDATION---------------------------
			ELSE IF @COLUMN_NAME = 'BANK_ACCOUNT' And @COLUMN_VALUE <> '' And @COLUMN_VALUE <> '0'
				BEGIN
																			
						 
							SELECT  @EMP_FULL_NAME = STUFF(
															 (SELECT ',' + (Em.Alpha_Emp_Code + ' - ' + Em.Emp_Full_Name)
															  FROM	T0070_EMP_INCREMENT_APP I WITH (NOLOCK) INNER JOIN
																				(
																					SELECT	MAX(TI.INCREMENT_ID) INCREMENT_ID,TI.Emp_Tran_ID 
																					FROM	T0070_EMP_INCREMENT_APP TI WITH (NOLOCK) INNER JOIN
																							(
																								SELECT	MAX(INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE,Emp_Tran_ID 
																								FROM	T0070_EMP_INCREMENT_APP WITH (NOLOCK)
																								WHERE	INCREMENT_EFFECTIVE_DATE <= GETDATE() AND INCREMENT_TYPE <> 'TRANSFER' --and CMP_ID = @Cmp_ID 
																								GROUP BY Emp_Tran_ID
																							 ) NEW_INC ON TI.Emp_Tran_ID = NEW_INC.Emp_Tran_ID AND TI.INCREMENT_EFFECTIVE_DATE=NEW_INC.INCREMENT_EFFECTIVE_DATE
																					WHERE	TI.INCREMENT_EFFECTIVE_DATE <= GETDATE() AND INCREMENT_TYPE <> 'TRANSFER' --and TI.CMP_ID = @Cmp_ID 
																					GROUP BY TI.Emp_Tran_ID		
																				 ) QRY_TEMP ON QRY_TEMP.INCREMENT_ID = I.INCREMENT_ID AND QRY_TEMP.Emp_Tran_ID = I.Emp_Tran_ID INNER JOIN 
																				 T0060_EMP_MASTER_APP Em WITH (NOLOCK) On EM.Emp_Tran_ID = I.Emp_Tran_ID --and Em.Increment_ID = I.Increment_ID
															  WHERE	(Inc_Bank_AC_No = @COLUMN_VALUE or 
																	 Inc_Bank_AC_No_Two = @COLUMN_VALUE)
																	 --AND I.CMP_ID = @CMP_ID	
																	 AND Em.Emp_Left <> 'Y'						
																	 ANd Em.Emp_Tran_ID <> @Emp_Tran_ID FOR XML PATH ('')), 1, 1, ''
														)	
						 
							IF @EMP_FULL_NAME <> ''							
										BEGIN
												SELECT	@EMP_FULL_NAME AS EMP_FULL_NAME											
										END
						
				END
			
		
			------------------------------------END-------------------------------------------
			-----------------------------PAN CARD NO NOMINEE OR FAMILY VALIDATION-----------------------
			ELSE IF (@COLUMN_NAME = 'PAN_NO_NOMINEE' OR @COLUMN_NAME = 'AADHAR_NO_NOMINEE') And @COLUMN_VALUE <> '' And @COLUMN_VALUE <> '0'
				BEGIN
																			
						 
							SELECT  @EMP_FULL_NAME = STUFF(
															 (SELECT ',' + (Em.Alpha_Emp_Code + ' - ' + Em.Emp_Full_Name)
															  FROM	T0065_EMP_DEPENDANT_DETAIL_APP ED WITH (NOLOCK) INNER JOIN
																	T0060_EMP_MASTER_APP EM WITH (NOLOCK) ON EM.Emp_Tran_ID = ED.Emp_Tran_ID --and Em.Increment_ID = I.Increment_ID
															  WHERE	(case when @COLUMN_NAME  = 'PAN_NO_NOMINEE'  then Ed.Pan_Card_No when @COLUMN_NAME  = 'AADHAR_NO_NOMINEE' then Ed.Adhar_Card_No end) = @COLUMN_VALUE 
																	 AND ED.CMP_ID = @CMP_ID
																	 		
																	 AND Em.Emp_Left <> 'Y'	
																	
																FOR XML PATH ('')), 1, 1, ''
														)	
						 
							IF @EMP_FULL_NAME <> ''							
										BEGIN
												SELECT	@EMP_FULL_NAME AS EMP_FULL_NAME											
										END
						
				END
			ELSE IF (@COLUMN_NAME = 'PAN_NO_FAMILY' OR @COLUMN_NAME = 'AADHAR_NO_FAMILY') And @COLUMN_VALUE <> '' And @COLUMN_VALUE <> '0'
				BEGIN
																			
						 
							SELECT  @EMP_FULL_NAME = STUFF(
															 (SELECT ',' + (Em.Alpha_Emp_Code + ' - ' + Em.Emp_Full_Name)
															  FROM	T0065_EMP_CHILDRAN_DETAIL_APP ED WITH (NOLOCK) INNER JOIN
																	T0060_EMP_MASTER_APP EM WITH (NOLOCK) ON EM.Emp_Tran_ID = ED.Emp_Tran_ID --and Em.Increment_ID = I.Increment_ID
															  WHERE	 (case when @COLUMN_NAME  = 'PAN_NO_FAMILY'  then Ed.Pan_Card_No when @COLUMN_NAME  = 'AADHAR_NO_FAMILY' then Ed.Adhar_Card_No end) = @COLUMN_VALUE
																	 AND ED.CMP_ID = @CMP_ID
																	 AND Em.Emp_Left <> 'Y'						
																	 --ANd Em.Emp_Tran_ID <> @Emp_Tran_ID 
																	 --			
																FOR XML PATH ('')), 1, 1, ''
														)	
						 
							IF @EMP_FULL_NAME <> ''							
										BEGIN
												SELECT	@EMP_FULL_NAME AS EMP_FULL_NAME											
										END
						
				END
			
			---------------------------------------END----------------------------------------
			
			
			
	RETURN

