CREATE PROCEDURE [dbo].[P_EMP_UAN_PAN_VALIDATION]
	 @CMP_ID			Int
	,@EMP_ID			Int  =0
	,@EMP_FIRST_NAME	VARCHAR(50) = ''
	,@EMP_LAST_NAME		VARCHAR(50) = ''
	,@DATE_OF_BIRTH		VARCHAR(20) = ''
	,@PAN_NO			VARCHAR(10) = ''
	--,@UAN_NO			VARCHAR(20) = ''
	,@COLUMN_NAME		VARCHAR(20) 
	,@COLUMN_VALUE		VARCHAR(100)
	,@Emp_Tran_ID		bigint  =0	
	
	
AS
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET ARITHABORT ON ;
	SET NOCOUNT ON; 
	
			DECLARE @EMP_LEFT AS VARCHAR = ''
			DECLARE @UANNO	  AS VARCHAR(20)
			DECLARE @PANNO	  AS VARCHAR(10)
			DECLARE @EMPID	  AS NUMERIC
			DECLARE @PFNO	  AS VARCHAR(25)
			DECLARE	@ESICNO	  AS VARCHAR(25)
			DECLARE @AADHARNO AS VARCHAR(25)
			DECLARE @lEmp_No AS NUMERIC =0
			DECLARE @EMP_FULL_NAME  AS VARCHAR(MAX) = ''
			-------------------------FOR UAN NO VALIDATION-----------------
			/*
					IF EMPLOYEE REJOIN IN THE COMPANY THEN CHECK 
						IF		EMPLOYEE IS SAME AS PREVIOUS ONE USING HIS/HER FIRST,LAST NAME AND BIRTH DATE THEN
								NO NEED TO VERIFY UAN,PAN,PF AND ESIC NO 
						ELSE	NEED TO VERIFY
					ELSE CHECK IF ENTER UAN,PAN,PF AND ESIC NO IS EXISTS THEN NOT ENTER SAME VALUE FOR THEM			
			*/	
			
			Declare @Emp_Application_Id AS Integer
			SET @Emp_Application_Id= (select Emp_Application_ID from T0060_EMP_MASTER_APP WITH (NOLOCK) where Emp_Tran_ID=@Emp_Tran_ID )
			SET @Emp_Application_Id=isnull(@Emp_Application_Id,0)
			
			DEclare @EmpId1 as numeric(18,0) = NULL -- Added by tejas for validation 

			IF @COLUMN_NAME = 'ALL'
				BEGIN
						--DECLARE @COLUMN_NAME VARCHAR(128)
						--DECLARE @COLUMN_VALUE VARCHAR(MAX)
					
						--Added By Ramiz on 24/04/2019 , as it was throwing Error  , when ALL Keyword is Passed
						SELECT @DATE_OF_BIRTH = CONVERT(VARCHAR(20) , DATE_OF_BIRTH , 105) ,
								@EMP_FIRST_NAME = ISNULL(EMP_FIRST_NAME,''),
								@EMP_LAST_NAME = ISNULL(EMP_LAST_NAME,''),
								@PAN_NO = PAN_NO 
						From(
									SELECT	DATE_OF_BIRTH,EMP_FIRST_NAME,EMP_LAST_NAME,PAN_NO											
									FROM	T0080_EMP_MASTER WITH (NOLOCK)  
									WHERE	EMP_ID = IsNULL(@EMP_ID,0) AND CMP_ID = @CMP_ID 
									UNION  
									SELECT	DATE_OF_BIRTH,EMP_FIRST_NAME,EMP_LAST_NAME,PAN_NO		
									FROM	T0060_EMP_MASTER_APP WITH (NOLOCK) 
									WHERE	Emp_Tran_ID = IsNULL(@Emp_Tran_ID,0) AND CMP_ID = @CMP_ID
						) AS x


						IF OBJECT_Id('TEMP.DB..#COLUMNS') is not null
							DROP TABLE #COLUMNS

						CREATE TABLE #COLUMNS
						(
							COLUMN_NAME		VARCHAR(50) default '',
							COLUMN_VALUE	VARCHAR(50) default ''
						)

						DECLARE @Emp_Column_Value as VARCHAR(30)
						--Declare @CUR_COLUMN_NAME  as VARCHAR(30)	
						Declare @CUR_COLUMN_VALUE as Varchar(30)



						DECLARE CUR_EMP CURSOR FOR
						select [data] from dbo.split(@COLUMN_VALUE, ',')
						OPEN  CUR_EMP      
							FETCH NEXT FROM CUR_EMP INTO @CUR_COLUMN_VALUE
							WHILE @@FETCH_STATUS = 0      
								BEGIN      
										SET @COLUMN_NAME = SUBSTRING(@CUR_COLUMN_VALUE, 0, CHARINDEX('::',@CUR_COLUMN_VALUE))
										SET @COLUMN_VALUE = SUBSTRING(@CUR_COLUMN_VALUE, CHARINDEX('::',@CUR_COLUMN_VALUE)+2, LEN(@CUR_COLUMN_VALUE))

										IF IsNull(@COLUMN_VALUE,'0') = '0' --Mukti(09052019)
										SET @COLUMN_VALUE = ''
										--Insert INTO #COLUMNS
										--SELECT @COLUMN_NAME, @COLUMN_VALUE

										INsert INto #COLUMNS
										EXEC P_EMP_UAN_PAN_VALIDATION @CMP_ID,@EMP_ID,@EMP_FIRST_NAME,@EMP_LAST_NAME,@DATE_OF_BIRTH,@PAN_NO,@COLUMN_NAME,@COLUMN_VALUE,@Emp_Tran_ID


							Fetch next FROM CUR_EMP  into @CUR_COLUMN_VALUE
							END      
						close CUR_EMP      
						Deallocate CUR_EMP  

						delete from #COLUMNS where COLUMN_VALUE = ''

						select * from #COLUMNS

				END				
			ELSE IF @COLUMN_NAME = 'UAN' And @COLUMN_VALUE <> '' And @COLUMN_VALUE <> '0'
				BEGIN
					If @EMP_ID = 0
					BEGIN
						Select @EmpId1 = EMp_Id from T0060_EMP_MASTER_APP where Emp_Application_ID = IsNULL(@Emp_Application_Id,0)
					END
					Select 	@UANNO = UAN_NO,@EMPID = EMP_ID,@EMP_LEFT = EMP_LEFT
					FROM (						
						SELECT	 UAN_NO,EMP_ID,EMP_LEFT
						FROM	T0080_EMP_MASTER WITH (NOLOCK)  
						WHERE	UAN_NO = @COLUMN_VALUE AND EMP_ID <> IsNULL(@EmpId1,@EMP_ID)
								AND CMP_ID = @CMP_ID 
						UNION  
						SELECT	UAN_NO,EMP_ID,EMP_LEFT
						FROM	T0060_EMP_MASTER_APP WITH (NOLOCK)  
						WHERE	UAN_NO = @COLUMN_VALUE AND Emp_Application_ID <> IsNULL(@Emp_Application_Id,0)
								AND CMP_ID = @CMP_ID 		
												
					) as X		
					
					IF @EMP_LEFT = 'Y'  AND	@UANNO IS NOT NULL 
						BEGIN	
						
							IF NOT EXISTS(
											SELECT	1 
											FROM	T0080_EMP_MASTER WITH (NOLOCK)  
											WHERE	EMP_ID = @EMPID AND
													ISNULL(PAN_NO,'') = CASE WHEN @PAN_NO = '' THEN ISNULL(PAN_NO,'') ELSE ISNULL(@PAN_NO,PAN_NO) END AND 
													DATE_OF_BIRTH = CASE WHEN ISNULL(CONVERT(DATETIME , @DATE_OF_BIRTH , 103),'') = '' THEN DATE_OF_BIRTH
																	ELSE CONVERT(DATETIME , @DATE_OF_BIRTH , 103)  END
													AND	UPPER(EMP_FIRST_NAME) =  UPPER(@EMP_FIRST_NAME) 
													AND	(UPPER(EMP_LAST_NAME) = UPPER(@EMP_LAST_NAME) OR @EMP_LAST_NAME = '')
													
											UNION ALL 
											SELECT	1 
											FROM	T0060_EMP_MASTER_APP WITH (NOLOCK)  
											WHERE	Emp_Application_ID = IsNULL(@Emp_Application_Id,0) AND
													ISNULL(PAN_NO,'') = CASE WHEN @PAN_NO = '' THEN ISNULL(PAN_NO,'') ELSE ISNULL(@PAN_NO,PAN_NO) END AND 
													DATE_OF_BIRTH = CASE WHEN ISNULL(CONVERT(DATETIME , @DATE_OF_BIRTH , 103),'') = '' THEN DATE_OF_BIRTH
																	ELSE CONVERT(DATETIME , @DATE_OF_BIRTH , 103)  END
													AND	UPPER(EMP_FIRST_NAME) =  UPPER(@EMP_FIRST_NAME) 
													AND	(UPPER(EMP_LAST_NAME) = UPPER(@EMP_LAST_NAME) OR @EMP_LAST_NAME = '')
																					
										  )											
											BEGIN																				
													SELECT	'UAN',@COLUMN_VALUE	AS UAN_NO													
											END
						END
					ELSE
						BEGIN
								IF EXISTS(
											SELECT	1 
											FROM	T0080_EMP_MASTER WITH (NOLOCK)  
											WHERE	UAN_NO = @COLUMN_VALUE
													AND CMP_ID = @CMP_ID	
													AND Emp_ID <> IsNULL(@EmpId1,@EMP_ID)	
											UNION ALL 	
											SELECT	1 
											FROM	T0060_EMP_MASTER_APP WITH (NOLOCK)  
											WHERE	UAN_NO = @COLUMN_VALUE
													AND CMP_ID = @CMP_ID	
													AND Emp_Application_ID <> IsNULL(@Emp_Application_Id,0)
													
															
										)											
											BEGIN																							
												SELECT	'UAN',@COLUMN_VALUE	AS UAN_NO,@EMPID as Emp_ID													
											END
							END			
						
				END
			-------------------------FOR PAN NO VALIDATION-----------------
			
			ELSE IF @COLUMN_NAME = 'PAN' And @COLUMN_VALUE <> '' And @COLUMN_VALUE <> '0'
				BEGIN
					If @EMP_ID = 0
					BEGIN
						Select @EmpId1 = EMp_Id from T0060_EMP_MASTER_APP where Emp_Application_ID = IsNULL(@Emp_Application_Id,0)
					END
				
					Select 	@PANNO = PAN_NO,@EMPID = EMP_ID,@EMP_LEFT = EMP_LEFT
					FROM (	
							SELECT	PAN_NO, EMP_ID, EMP_LEFT
							FROM	T0080_EMP_MASTER WITH (NOLOCK)  
							WHERE	PAN_NO = @COLUMN_VALUE AND EMP_ID <> IsNULL(@EmpId1,@EMP_ID)
									AND CMP_ID = @CMP_ID
							UNION  		
							SELECT	PAN_NO, EMP_ID, EMP_LEFT
							FROM	T0060_EMP_MASTER_APP WITH (NOLOCK)  
							WHERE	PAN_NO = @COLUMN_VALUE AND Emp_Application_ID <> IsNULL(@Emp_Application_Id,0) 
									AND CMP_ID = @CMP_ID											
						) As X
					
					IF @EMP_LEFT = 'Y' AND @PANNO IS NOT NULL
						BEGIN	
							IF NOT EXISTS(
											SELECT	1
											FROM	T0080_EMP_MASTER WITH (NOLOCK)  
											WHERE	EMP_ID = @EMPID AND													
													DATE_OF_BIRTH = CASE WHEN ISNULL(CONVERT(DATETIME , @DATE_OF_BIRTH , 103),'') = '' THEN DATE_OF_BIRTH
																	ELSE CONVERT(DATETIME , @DATE_OF_BIRTH , 103)  END   
													AND	UPPER(EMP_FIRST_NAME) =  UPPER(@EMP_FIRST_NAME) 
													AND	UPPER(EMP_LAST_NAME) = UPPER(@EMP_LAST_NAME)
											UNION ALL 	
											SELECT	1
											FROM	T0060_EMP_MASTER_APP WITH (NOLOCK)  
											WHERE	Emp_Application_ID = IsNULL(@Emp_Application_Id,0) AND													
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
										FROM	T0080_EMP_MASTER WITH (NOLOCK)  
										WHERE	PAN_NO = @COLUMN_VALUE
												AND CMP_ID = @CMP_ID
												AND Emp_ID <> IsNULL(@EmpId1,@EMP_ID)
										UNION ALL 	
										SELECT	1 
										FROM	T0060_EMP_MASTER_APP WITH (NOLOCK)  
										WHERE	PAN_NO = @COLUMN_VALUE
												AND CMP_ID = @CMP_ID AND Emp_ID <> IsNULL(@EmpId1,@EMP_ID)
												AND Emp_Application_ID <> IsNULL(@Emp_Application_Id,0)	
												
									 )											
										BEGIN	
												SELECT	'PAN',@COLUMN_VALUE	AS	PAN_NO,@EMPID as Emp_ID													
										END
						END
				END
				
			-------------------------FOR PF NO VALIDATION-----------------
			ELSE IF @COLUMN_NAME = 'PF' And @COLUMN_VALUE <> '' And @COLUMN_VALUE <> '0'
				BEGIN
				If @EMP_ID = 0
					BEGIN
						Select @EmpId1 = EMp_Id from T0060_EMP_MASTER_APP where Emp_Application_ID = IsNULL(@Emp_Application_Id,0)
					END
				SELECT @PFNO = SSN_NO ,@EMPID = EMP_ID,@EMP_LEFT = EMP_LEFT
				FROM(
					SELECT	 SSN_NO , EMP_ID, EMP_LEFT
					FROM	T0080_EMP_MASTER WITH (NOLOCK)  
					WHERE	EMP_ID <> IsNULL(@EmpId1,@EMP_ID)  AND
							 CMP_ID = @CMP_ID AND SSN_NO = @COLUMN_VALUE
					UNION 
					SELECT	SSN_NO , EMP_ID, EMP_LEFT
					FROM	T0060_EMP_MASTER_APP WITH (NOLOCK)  
					WHERE	Emp_Application_ID <> IsNULL(@Emp_Application_Id,0)  AND
							 CMP_ID = @CMP_ID AND SSN_NO = @COLUMN_VALUE
					) AS X
					
					IF @EMP_LEFT = 'Y' AND @PFNO IS NOT NULL
						BEGIN	
							IF NOT EXISTS(
											SELECT	1
											FROM	T0080_EMP_MASTER WITH (NOLOCK)  
											WHERE	EMP_ID = @EMPID AND																										
													DATE_OF_BIRTH = CASE WHEN ISNULL(CONVERT(DATETIME , @DATE_OF_BIRTH , 103),'') = '' THEN DATE_OF_BIRTH
																	ELSE CONVERT(DATETIME , @DATE_OF_BIRTH , 103)  END   
													AND	UPPER(EMP_FIRST_NAME) =  UPPER(@EMP_FIRST_NAME) 
													AND	UPPER(EMP_LAST_NAME) = UPPER(@EMP_LAST_NAME)
											UNION ALL
											SELECT	1
											FROM	T0060_EMP_MASTER_APP WITH (NOLOCK)  
											WHERE	Emp_Application_ID = IsNULL(@Emp_Application_Id,0) AND																										
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
										FROM	T0080_EMP_MASTER WITH (NOLOCK)  
										WHERE	SSN_NO = @COLUMN_VALUE
												AND CMP_ID = @CMP_ID
												AND Emp_ID <> IsNULL(@EmpId1,@EMP_ID)
										UNION ALL
										SELECT	1 
										FROM	T0060_EMP_MASTER_APP WITH (NOLOCK)  
										WHERE	SSN_NO = @COLUMN_VALUE
												AND CMP_ID = @CMP_ID
												AND Emp_Application_ID <> IsNULL(@Emp_Application_Id,0)							
									 )											
										BEGIN
												SELECT	'PF',@COLUMN_VALUE	AS	SSN_NO,@EMPID as Emp_ID													
										END
						END
				END
				
				-------------------------FOR ESIC NO VALIDATION-----------------
				ELSE IF @COLUMN_NAME = 'ESIC' And @COLUMN_VALUE <> '' And @COLUMN_VALUE <> '0'
				BEGIN
					If @EMP_ID = 0
					BEGIN
						Select @EmpId1 = EMp_Id from T0060_EMP_MASTER_APP where Emp_Application_ID = IsNULL(@Emp_Application_Id,0)
					END
					SELECT @ESICNO = SIN_NO,@EMPID = EMP_ID,@EMP_LEFT = EMP_LEFT
					FROM (
								SELECT	 SIN_NO, EMP_ID, EMP_LEFT
								FROM	T0080_EMP_MASTER WITH (NOLOCK)  
								WHERE	SIN_NO = @COLUMN_VALUE AND EMP_ID <> IsNULL(@EmpId1,@EMP_ID) 
										AND CMP_ID = @CMP_ID
								UNION 
								SELECT	SIN_NO, EMP_ID, EMP_LEFT
								FROM	T0060_EMP_MASTER_APP WITH (NOLOCK)  
								WHERE	SIN_NO = @COLUMN_VALUE AND Emp_Application_ID <> IsNULL(@Emp_Application_Id,0) 
										AND CMP_ID = @CMP_ID
						)  AS X
					
					
					IF @EMP_LEFT = 'Y' AND @ESICNO IS NOT NULL AND @COLUMN_VALUE <> '0'
						BEGIN	
							IF NOT EXISTS(
											SELECT	1
											FROM	T0080_EMP_MASTER WITH (NOLOCK)  
											WHERE	EMP_ID = @EMPID AND													
													DATE_OF_BIRTH = CASE WHEN ISNULL(CONVERT(DATETIME , @DATE_OF_BIRTH , 103),'') = '' THEN DATE_OF_BIRTH
																	ELSE CONVERT(DATETIME , @DATE_OF_BIRTH , 103)  END   
													AND	UPPER(EMP_FIRST_NAME) =  UPPER(@EMP_FIRST_NAME) 
													AND	UPPER(EMP_LAST_NAME) = UPPER(@EMP_LAST_NAME)
											UNION ALL
											SELECT	1
											FROM	T0060_EMP_MASTER_APP WITH (NOLOCK)  
											WHERE	Emp_Application_ID = IsNULL(@Emp_Application_Id,0) AND													
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
										FROM	T0080_EMP_MASTER WITH (NOLOCK)  
										WHERE	SIN_NO = @COLUMN_VALUE
												AND CMP_ID = @CMP_ID
												AND Emp_ID <> IsNULL(@EmpId1,@EMP_ID)	AND @COLUMN_VALUE <> '0'	
										UNION ALL
										SELECT	1 
										FROM	T0060_EMP_MASTER_APP WITH (NOLOCK)  
										WHERE	SIN_NO = @COLUMN_VALUE
												AND CMP_ID = @CMP_ID
												AND Emp_Application_ID <> IsNULL(@Emp_Application_Id,0)	AND @COLUMN_VALUE <> '0'					
									 )											
										BEGIN
												SELECT	'ESIC',@COLUMN_VALUE	AS	ESIC_NO,@EMPID as Emp_ID													
										END
						END
				END
			-----------------------------AADHAR CARD NO VALIDATION---------------------------
			
			
			ELSE IF @COLUMN_NAME = 'AADHAR' And @COLUMN_VALUE <> '' And @COLUMN_VALUE <> '0'
				BEGIN

				If @EMP_ID = 0
				BEGIN
					Select @EmpId1 = EMp_Id from T0060_EMP_MASTER_APP where Emp_Application_ID = IsNULL(@Emp_Application_Id,0)
				END
				
				 SELECT @AADHARNO = AADHAR_CARD_NO,@EMPID = EMP_ID,@EMP_LEFT = EMP_LEFT,@lEmp_No =  Emp_ID
				 FROM 
				 (
					SELECT	AADHAR_CARD_NO, EMP_ID, EMP_LEFT
					FROM	T0080_EMP_MASTER WITH (NOLOCK)  
					WHERE	AADHAR_CARD_NO = @COLUMN_VALUE AND EMP_ID <> IsNULL(@EmpId1,@EMP_ID)
							AND CMP_ID = @CMP_ID 							
					UNION 
					SELECT	AADHAR_CARD_NO, EMP_ID , EMP_LEFT
					FROM	T0060_EMP_MASTER_APP WITH (NOLOCK)  
					WHERE	AADHAR_CARD_NO = @COLUMN_VALUE AND Emp_Application_ID <> IsNULL(@Emp_Application_Id,0)
							AND CMP_ID = @CMP_ID 
				)AS X
						 					

				
					IF @EMP_LEFT = 'Y' AND @AADHARNO IS NOT NULL	
						BEGIN	
						
							IF NOT EXISTS(
											SELECT	1
											FROM	T0080_EMP_MASTER WITH (NOLOCK)  
											WHERE	EMP_ID = @EMPID AND													
													DATE_OF_BIRTH = CASE WHEN ISNULL(CONVERT(DATETIME , @DATE_OF_BIRTH , 103),'') = '' THEN DATE_OF_BIRTH
																	ELSE CONVERT(DATETIME , @DATE_OF_BIRTH , 103)  END   
													AND	UPPER(EMP_FIRST_NAME) =  UPPER(@EMP_FIRST_NAME) 
													AND	UPPER(EMP_LAST_NAME) = UPPER(@EMP_LAST_NAME)	
											UNION ALL
											SELECT	1
											FROM	T0060_EMP_MASTER_APP WITH (NOLOCK)  
											WHERE	Emp_Application_ID = IsNULL(@Emp_Application_Id,0) AND													
													DATE_OF_BIRTH = CASE WHEN ISNULL(CONVERT(DATETIME , @DATE_OF_BIRTH , 103),'') = '' THEN DATE_OF_BIRTH
																	ELSE CONVERT(DATETIME , @DATE_OF_BIRTH , 103)  END   
													AND	UPPER(EMP_FIRST_NAME) =  UPPER(@EMP_FIRST_NAME) 
													AND	UPPER(EMP_LAST_NAME) = UPPER(@EMP_LAST_NAME)	
													
													
											)											
												BEGIN
												
														SELECT	'AADHAR',@COLUMN_VALUE	AS	AADHAR_CARD_NO,@lEmp_No as Emp_ID												
												END
						END										
					ELSE
						BEGIN	
						
							IF EXISTS(
										SELECT	1 
										FROM	T0080_EMP_MASTER WITH (NOLOCK)  
										WHERE	AADHAR_CARD_NO = @COLUMN_VALUE
												AND CMP_ID = @CMP_ID
												AND Emp_ID <> IsNULL(@EmpId1,@EMP_ID)
										UNION ALL
										SELECT	1 
										FROM	T0060_EMP_MASTER_APP WITH (NOLOCK)  
										WHERE	AADHAR_CARD_NO = @COLUMN_VALUE
												AND CMP_ID = @CMP_ID
												AND Emp_Application_ID <> IsNULL(@Emp_Application_Id,0)							
									 )											
										BEGIN
													SELECT	'AADHAR',@COLUMN_VALUE	AS	AADHAR_CARD_NO,@lEmp_No as Emp_ID													
										END
						END
				END
			-----------------------------END---------------------------
			-----------------------------BANK ACCOUNT NO VALIDATION---------------------------
			ELSE IF @COLUMN_NAME = 'BANK_ACCOUNT' And @COLUMN_VALUE <> '' And @COLUMN_VALUE <> '0'
				BEGIN
						If @EMP_ID = 0
							BEGIN
								Select @EmpId1 = EMp_Id from T0060_EMP_MASTER_APP where Emp_Application_ID = IsNULL(@Emp_Application_Id,0)
							END 


						SELECT  @EMP_FULL_NAME = STUFF(
															 (
																Select Name FROM (
																	SELECT ',' + (Em.Alpha_Emp_Code + ' - ' + Em.Emp_Full_Name + '#' + CAST(Em.Emp_ID as varchar) + '#') as Name
																		FROM	T0095_INCREMENT I WITH (NOLOCK)  INNER JOIN
																					(
																						SELECT	MAX(TI.INCREMENT_ID) INCREMENT_ID,TI.EMP_ID 
																						FROM	T0095_INCREMENT TI WITH (NOLOCK)  INNER JOIN
																								(
																									SELECT	MAX(INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE,EMP_ID 
																									FROM	T0095_INCREMENT WITH (NOLOCK) 
																									WHERE	INCREMENT_EFFECTIVE_DATE <= GETDATE() AND INCREMENT_TYPE <> 'TRANSFER' --and CMP_ID = @Cmp_ID 
																									GROUP BY EMP_ID
																								 ) NEW_INC ON TI.EMP_ID = NEW_INC.EMP_ID AND TI.INCREMENT_EFFECTIVE_DATE=NEW_INC.INCREMENT_EFFECTIVE_DATE
																						WHERE	TI.INCREMENT_EFFECTIVE_DATE <= GETDATE() AND INCREMENT_TYPE <> 'TRANSFER' --and TI.CMP_ID = @Cmp_ID 
																						GROUP BY TI.EMP_ID		
																					 ) QRY_TEMP ON QRY_TEMP.INCREMENT_ID = I.INCREMENT_ID AND QRY_TEMP.EMP_ID = I.EMP_ID INNER JOIN 
																					 T0080_EMP_MASTER Em WITH (NOLOCK)  On EM.Emp_ID = I.Emp_ID --and Em.Increment_ID = I.Increment_ID
																		 WHERE	(Inc_Bank_AC_No = @COLUMN_VALUE or 
																					 Inc_Bank_AC_No_Two = @COLUMN_VALUE)
																		 AND Em.Emp_Left <> 'Y'						
																		 ANd Em.Emp_Id <> IsNULL(@EmpId1,@EMP_ID)
																		 
																	 UNION
																	 
																	 SELECT ',' + (Em.Alpha_Emp_Code + ' - ' + Em.Emp_Full_Name + '#' + CAST(Em.Emp_ID as varchar) + '#') as Name
																		  FROM	T0070_EMP_INCREMENT_APP I WITH (NOLOCK)  INNER JOIN
																							(
																								SELECT	MAX(TI.INCREMENT_ID) INCREMENT_ID,TI.Emp_Tran_ID 
																								FROM	T0070_EMP_INCREMENT_APP TI WITH (NOLOCK)  INNER JOIN
																										(
																											SELECT	MAX(INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE,Emp_Tran_ID 
																											FROM	T0070_EMP_INCREMENT_APP WITH (NOLOCK) 
																											WHERE	INCREMENT_EFFECTIVE_DATE <= GETDATE() AND INCREMENT_TYPE <> 'TRANSFER' --and CMP_ID = @Cmp_ID 
																											GROUP BY Emp_Tran_ID
																										 ) NEW_INC ON TI.Emp_Tran_ID = NEW_INC.Emp_Tran_ID AND TI.INCREMENT_EFFECTIVE_DATE=NEW_INC.INCREMENT_EFFECTIVE_DATE
																								WHERE	TI.INCREMENT_EFFECTIVE_DATE <= GETDATE() AND INCREMENT_TYPE <> 'TRANSFER' --and TI.CMP_ID = @Cmp_ID 
																								GROUP BY TI.Emp_Tran_ID		
																							 ) QRY_TEMP ON QRY_TEMP.INCREMENT_ID = I.INCREMENT_ID AND QRY_TEMP.Emp_Tran_ID = I.Emp_Tran_ID INNER JOIN 
																							 T0060_EMP_MASTER_APP Em WITH (NOLOCK)  On EM.Emp_Tran_ID = I.Emp_Tran_ID --and Em.Increment_ID = I.Increment_ID
																		  WHERE	(Inc_Bank_AC_No = @COLUMN_VALUE or 
																				 Inc_Bank_AC_No_Two = @COLUMN_VALUE)
																				 --AND I.CMP_ID = @CMP_ID	
																				 AND Em.Emp_Left <> 'Y'						
																				 ANd Em.Emp_Tran_ID <> isnull(@Emp_Tran_ID,0)
																	 
																	 
																	 )  As X
																	 
																	 
																	 FOR XML PATH ('')																	 
															 ) , 1, 1, ''
														)	
						 
						IF @EMP_FULL_NAME <> ''							
							BEGIN
									SELECT	'BANK_ACCOUNT' ,@COLUMN_VALUE AS BANK_ACCOUNT,@EMP_FULL_NAME as EMP_FULL_NAME
							END
						
				END
			
		
			------------------------------------END-------------------------------------------
			-----------------------------PAN CARD NO NOMINEE OR FAMILY VALIDATION-----------------------
			ELSE IF (@COLUMN_NAME = 'PAN_NO_NOMINEE' OR @COLUMN_NAME = 'AADHAR_NO_NOMINEE') And @COLUMN_VALUE <> '' And @COLUMN_VALUE <> '0'
				BEGIN
																			
						 
							SELECT  @EMP_FULL_NAME = STUFF(
															 (
															 
															Select Name FROM (
																SELECT ',' + (Em.Alpha_Emp_Code + ' - ' + Em.Emp_Full_Name) as Name
																FROM	T0090_EMP_DEPENDANT_DETAIL ED WITH (NOLOCK)  INNER JOIN
																		T0080_EMP_MASTER EM WITH (NOLOCK)  ON EM.Emp_ID = ED.Emp_ID --and Em.Increment_ID = I.Increment_ID
																 WHERE	(case when @COLUMN_NAME  = 'PAN_NO_NOMINEE'  then Ed.Pan_Card_No when @COLUMN_NAME  = 'AADHAR_NO_NOMINEE' then Ed.Adhar_Card_No end) = @COLUMN_VALUE 
																	 AND ED.CMP_ID = @CMP_ID
																	 AND Em.Emp_Left <> 'Y'						
																	
																UNION 
																SELECT ',' + (Em.Alpha_Emp_Code + ' - ' + Em.Emp_Full_Name) as Name
																  FROM	T0065_EMP_DEPENDANT_DETAIL_APP ED WITH (NOLOCK)  INNER JOIN
																		T0060_EMP_MASTER_APP EM WITH (NOLOCK)  ON EM.Emp_Tran_ID = ED.Emp_Tran_ID --and Em.Increment_ID = I.Increment_ID
																  WHERE	(case when @COLUMN_NAME  = 'PAN_NO_NOMINEE'  then Ed.Pan_Card_No when @COLUMN_NAME  = 'AADHAR_NO_NOMINEE' then Ed.Adhar_Card_No end) = @COLUMN_VALUE 
																		 AND ED.CMP_ID = @CMP_ID
																		 		
																		 AND Em.Emp_Left <> 'Y'	
																
																	 
															    ) as x
																	 
																FOR XML PATH ('')																											
																), 1, 1, ''
															)	
						 
							IF @EMP_FULL_NAME <> ''							
										BEGIN
												SELECT	@EMP_FULL_NAME AS EMP_FULL_NAME											
										END
						
				END
			ELSE IF (@COLUMN_NAME = 'PAN_NO_FAMILY' OR @COLUMN_NAME = 'AADHAR_NO_FAMILY') And @COLUMN_VALUE <> '' And @COLUMN_VALUE <> '0'
				BEGIN
																			
						 
							SELECT  @EMP_FULL_NAME = STUFF(
															 (
															Select Name FROM (
																SELECT ',' + (Em.Alpha_Emp_Code + ' - ' + Em.Emp_Full_Name)  as Name
																  FROM	T0090_EMP_CHILDRAN_DETAIL ED WITH (NOLOCK)  INNER JOIN
																		T0080_EMP_MASTER EM WITH (NOLOCK)  ON EM.Emp_ID = ED.Emp_ID --and Em.Increment_ID = I.Increment_ID
																  WHERE	 (case when @COLUMN_NAME  = 'PAN_NO_FAMILY'  then Ed.Pan_Card_No when @COLUMN_NAME  = 'AADHAR_NO_FAMILY' then Ed.Adhar_Card_No end) = @COLUMN_VALUE
																		 AND ED.CMP_ID = @CMP_ID
																		 AND Em.Emp_Left <> 'Y'			
																UNION
																SELECT ',' + (Em.Alpha_Emp_Code + ' - ' + Em.Emp_Full_Name)  as Name
																  FROM	T0065_EMP_CHILDRAN_DETAIL_APP ED WITH (NOLOCK)  INNER JOIN
																		T0060_EMP_MASTER_APP EM WITH (NOLOCK)  ON EM.Emp_Tran_ID = ED.Emp_Tran_ID --and Em.Increment_ID = I.Increment_ID
																  WHERE	 (case when @COLUMN_NAME  = 'PAN_NO_FAMILY'  then Ed.Pan_Card_No when @COLUMN_NAME  = 'AADHAR_NO_FAMILY' then Ed.Adhar_Card_No end) = @COLUMN_VALUE
																		 AND ED.CMP_ID = @CMP_ID
																		 AND Em.Emp_Left <> 'Y'
																
																		 			
															  )as x
																		 
																		 
																	FOR XML PATH ('')
															  ), 1, 1, ''
														)	
						 
							IF @EMP_FULL_NAME <> ''							
										BEGIN
												SELECT	@EMP_FULL_NAME AS EMP_FULL_NAME											
										END
						
				END
			
			---------------------------------------END----------------------------------------
			
			
			
	RETURN	