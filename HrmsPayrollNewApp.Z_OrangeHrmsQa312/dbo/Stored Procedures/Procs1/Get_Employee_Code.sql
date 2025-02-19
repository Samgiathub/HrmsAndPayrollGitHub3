

---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[Get_Employee_Code]

 @Cmp_Id		numeric
,@Branch_Id		numeric
,@joiningDate	varchar(20) = ''
,@Get_Emp_Code	varchar(100) = '' output
,@Get_Alpha_Code	varchar(100) = '' Output
,@Is_Only_Emp_Code tinyint = 0
,@Desig_ID		NUMERIC = 0		--Ankit 23122014
,@Cate_ID		NUMERIC = 0		--Ankit 23122014
,@Type_ID		NUMERIC = 0		--Ankit 23122014
,@Date_OF_Birth VARCHAR(20) = ''	--Ankit 23122014
,@Grd_ID		NUMERIC = 0		--Hardik 31/10/2018 for Competent Client
AS
BEGIN
	
	
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	Declare @Cmp_Code varchar(50)
	Declare @Is_Auto_Alpha_Numeric_Code	tinyint
	Declare @No_Of_Digits numeric(18, 0)
	Declare @Is_Alpha_Numeric_Branchwise tinyint
	Declare @Branch_Code varchar(50)	
	Declare @Branch_Name varchar(50)
	Declare @Emp_Code varchar(50) 
	Declare @Alpha_Code varchar(50)
	Declare @Is_Alpha_Numeric_Companywise tinyint 
	Declare @Is_Date_Wise tinyint 
	Declare @is_JoiningDate_Wise tinyint 
	Declare @is_ResetSequance tinyint 
	Declare @Date_Format varchar(20) 
	Declare @Date_Code varchar(40) 
	Declare @Is_GroupOFCmp Numeric
	Declare @Max_Emp_Code  Varchar(50)
	Declare @Sample_Emp_Code Varchar(500)
	Declare @Is_DateOFBirth_Wise	tinyint
	Declare @Is_CurrentDate_Wise	tinyint
	Declare @DateOFBirth_Format		Varchar(20)
	Declare @CurrentDate_Format		Varchar(20)
	
	Set @Is_Date_Wise = 0
	set @Emp_Code = ''
	set @Is_Alpha_Numeric_Companywise = 0
	set @Is_Date_Wise = 0
	set @is_JoiningDate_Wise= 0
	set @is_ResetSequance = 0
	set @Date_Format = ''
	set @Date_Code = ''
	Set @Is_GroupOFCmp = 0
	Set @Max_Emp_Code = 'Company_Wise'
	Set @Is_DateOFBirth_Wise = 0
	Set @Is_CurrentDate_Wise = 0
	Set @DateOFBirth_Format = ''
	Set @CurrentDate_Format = '' 
	
    Select @Cmp_Code=isnull(Cmp_Code,''),@Is_Auto_Alpha_Numeric_Code=isnull(Is_Auto_Alpha_Numeric_Code,0)
		,@Is_Alpha_Numeric_Branchwise=isnull(Is_Alpha_Numeric_Branchwise,0),@No_Of_Digits=isnull(No_Of_Digit_Emp_Code,0),@Is_Alpha_Numeric_Companywise = ISNULL(Is_CompanyWise,0) 
		,@Is_Date_Wise = ISNULL(Is_DateWise,0),@is_JoiningDate_Wise = ISNULL(Is_JoiningDateWise,0),@Date_Format = ISNULL(DateFormat,'YYYYMMDD'),@is_ResetSequance = ISNULL(Reset_Sequance,0)
		,@Is_GroupOFCmp = ISNULL(Is_GroupOFCmp,0) ,@Max_Emp_Code = Max_Emp_Code	,@Sample_Emp_Code = Sample_Emp_Code 
		,@Is_DateOFBirth_Wise = ISNULL(Is_DateofBirth,0),@Is_CurrentDate_Wise = ISNULL(Is_Current_Date,0),@DateOFBirth_Format = ISNULL(DateFormat_Birth,'YYYYMMDD'),@CurrentDate_Format = ISNULL(DateFormat_Current,'YYYYMMDD')	--Ankit 12072014
    From T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@Cmp_Id
    
	

    IF @Is_Auto_Alpha_Numeric_Code = 1
		BEGIN
			Declare @DayJoiningDate as varchar(2) 
			Declare @MonthJoingDate as varchar(2)
			Declare @DayCurrentDate as varchar(2) 
			Declare @MonthCurrentDate as varchar(2) 
			Declare @MonthDate_OF_Birth As Varchar(2)
			Declare @DayDate_OF_Birth   As Varchar(2)
			
			set @DayJoiningDate  = ''
			set @MonthJoingDate = ''
			set @DayCurrentDate  = ''
			set @MonthCurrentDate   = ''
			set @MonthDate_OF_Birth = ''
			Set @DayDate_OF_Birth   = ''
			
			DECLARE @CurSample Varchar(100)
			DECLARE @Sample_Code varchar(100)
				SET @Sample_Code = ''
			
			Declare @JD_Date_Format Varchar(30)
			Declare @BD_Date_Format Varchar(30)
			Declare @CD_Date_Format Varchar(30)
				
			SET @JD_Date_Format = 'JD('+@Date_Format+')'
			SET @BD_Date_Format = 'BD('+@DateOFBirth_Format+')'
			SET @CD_Date_Format = 'CD('+@CurrentDate_Format+')'
			
			IF @Is_Alpha_Numeric_Branchwise = 1
				BEGIN
					SELECT  @Branch_Code=Branch_Code, @Branch_Name = Branch_Name 
					FROM	T0030_BRANCH_MASTER WITH (NOLOCK) WHERE Cmp_ID=@Cmp_Id and Branch_ID=@Branch_Id
					
					IF @BRANCH_CODE IS NULL
						SET @BRANCH_CODE = ''
					IF @BRANCH_NAME IS NULL
						SET @BRANCH_NAME = ''
				END
								
			IF @Sample_Emp_Code IS NULL
				BEGIN
					IF @Is_Alpha_Numeric_Companywise = 1
						SET @Sample_Emp_Code = @Cmp_Code
					Else IF @Is_Alpha_Numeric_Branchwise = 1
						SET @Sample_Emp_Code = @Branch_Code
					Else IF @Is_Alpha_Numeric_Companywise = 1 And @Is_Alpha_Numeric_Branchwise = 1
						SET @Sample_Emp_Code = @Cmp_Code + @Branch_Code
				END
			
			
			Declare CusrSample cursor for	                  
			select Data from dbo.Split(@Sample_Emp_Code,'+')
			Open CusrSample
			Fetch next from CusrSample into @CurSample
			While @@fetch_status = 0                    
				BEGIN     
				
					If @CurSample = 'CM'
						BEGIN
							SET @Sample_Code = @Sample_Code + @Cmp_Code
						END
					ELSE IF @CurSample = 'BR'
						BEGIN
							SET @Sample_Code = @Sample_Code + @Branch_Code
						END
					ELSE IF @CurSample = 'DE'
						BEGIN
							DECLARE @Desi_Code varchar(50)
								SET @Desi_Code = ''
							SELECT  @Desi_Code = Desig_Code
							FROM	T0040_DESIGNATION_MASTER WITH (NOLOCK) WHERE Cmp_ID=@Cmp_Id AND Desig_ID = @Desig_ID
							    
							IF @Desi_Code IS NULL
								SET @Desi_Code = ''
							
							SET @Sample_Code = @Sample_Code + @Desi_Code
						END
					ELSE IF @CurSample = 'CA'
						BEGIN
							DECLARE @Cate_Code varchar(50)
								SET @Cate_Code = ''
								
							SELECT  @Cate_Code = Cate_Code
							FROM	T0030_CATEGORY_MASTER WITH (NOLOCK) WHERE Cmp_ID=@Cmp_Id AND Cat_ID = @Cate_ID
							    
							IF @Cate_Code IS NULL
								SET @Cate_Code = ''
							
							SET @Sample_Code = @Sample_Code + @Cate_Code
						END
					ELSE IF @CurSample = 'TY'
						BEGIN
							DECLARE @Type_Code varchar(50)
								SET @Cate_Code = ''
								
							SELECT  @Type_Code = type_code
							FROM	T0040_TYPE_MASTER WITH (NOLOCK) WHERE Cmp_ID=@Cmp_Id AND Type_ID = @Type_ID
							    
							IF @Type_Code IS NULL
								SET @Type_Code = ''
							
							SET @Sample_Code = @Sample_Code + @Type_Code
						END
					ELSE IF (UPPER(@CurSample) = UPPER(@JD_Date_Format)) AND @is_JoiningDate_Wise = 1 AND  @joiningDate <> '' -- Joining Date 
						BEGIN
							IF DAY(@joiningDate) < 10
								set @DayJoiningDate = '0' + CONVERT(varchar(2), DAY(@joiningDate))
							else
								set @DayJoiningDate = CONVERT(varchar(2), DAY(@joiningDate))
									
							if Month(@joiningDate) < 10
								set @MonthJoingDate = '0' + CONVERT(varchar(2),Month(@joiningDate))
							else
								set  @MonthJoingDate = CONVERT(varchar(2), Month(@joiningDate))		
						
							
							IF  @Date_Format = 'DDMM'
								BEGIN
									IF @is_JoiningDate_Wise = 1 and  @joiningDate <> '' AND (UPPER(@CurSample) = UPPER(@JD_Date_Format))
										begin		
											set @Date_Code =  @DayJoiningDate + @MonthJoingDate
										end
								END
							ELSE IF @Date_Format = 'DDMMYY'
								BEGIN
									if @is_JoiningDate_Wise = 1 and  @joiningDate <> '' AND (UPPER(@CurSample) = UPPER(@JD_Date_Format))
										set @Date_Code =   @DayJoiningDate + @MonthJoingDate +  substring(Convert(varchar(4),Year(@joiningDate)),3,2)
								end
							ELSE IF @Date_Format = 'DDMMYYYY'
								BEGIN
									if @is_JoiningDate_Wise = 1 and  @joiningDate <> '' AND (UPPER(@CurSample) = UPPER(@JD_Date_Format))
										set @Date_Code =  @DayJoiningDate + @MonthJoingDate + CONVERT(varchar(4),Year(@joiningDate))
								END
							ELSE IF @Date_Format = 'MMDD'
								BEGIN
									IF @is_JoiningDate_Wise = 1 and  @joiningDate <> '' AND (UPPER(@CurSample) = UPPER(@JD_Date_Format))
										set @Date_Code =  @MonthJoingDate + @DayJoiningDate
								END
							ELSE IF @Date_Format = 'MMYY'
								BEGIN
									if @is_JoiningDate_Wise = 1 and  @joiningDate <> '' AND (UPPER(@CurSample) = UPPER(@JD_Date_Format))
										set @Date_Code =  @MonthJoingDate +  substring(Convert(varchar(4),Year(@joiningDate)),3,2)
								END	
							ELSE IF @Date_Format = 'MMYYYY'
								BEGIN
									if @is_JoiningDate_Wise = 1 and  @joiningDate <> '' AND (UPPER(@CurSample) = UPPER(@JD_Date_Format))
										set @Date_Code =  @MonthJoingDate + CONVERT(varchar(4),Year(@joiningDate))
								end
							ELSE IF @Date_Format = 'MMDDYY'
								BEGIN
									if @is_JoiningDate_Wise = 1 and  @joiningDate <> '' AND (UPPER(@CurSample) = UPPER(@JD_Date_Format))
										set @Date_Code =  @MonthJoingDate + @DayJoiningDate + substring(Convert(varchar(4),Year(@joiningDate)),3,2)
								end
							ELSE IF @Date_Format = 'MMDDYYYY'
								BEGIN
									if @is_JoiningDate_Wise = 1 and  @joiningDate <> '' AND (UPPER(@CurSample) = UPPER(@JD_Date_Format))
										set @Date_Code =  @MonthJoingDate + @DayJoiningDate+ Convert(varchar(4),Year(@joiningDate))
								end
							ELSE IF @Date_Format = 'MMYYDD'
								BEGIN
									if @is_JoiningDate_Wise = 1 and  @joiningDate <> '' AND (UPPER(@CurSample) = UPPER(@JD_Date_Format))
										set @Date_Code =  @MonthJoingDate + substring(Convert(varchar(4),Year(@joiningDate)),3,2) + @DayJoiningDate
								end
							ELSE IF @Date_Format = 'MMYYYYDD'
								BEGIN
									if @is_JoiningDate_Wise = 1 and  @joiningDate <> '' AND (UPPER(@CurSample) = UPPER(@JD_Date_Format))
										set @Date_Code =  @MonthJoingDate + Convert(varchar(4),Year(@joiningDate)) + @DayJoiningDate
								end
							ELSE IF @Date_Format = 'YYMM'
								BEGIN
									if @is_JoiningDate_Wise = 1 and  @joiningDate <> '' AND (UPPER(@CurSample) = UPPER(@JD_Date_Format))
										set @Date_Code =  substring(Convert(varchar(4),Year(@joiningDate)),3,2) + @MonthJoingDate
								end
							ELSE IF @Date_Format = 'YYDDMM'
								BEGIN
									if @is_JoiningDate_Wise = 1 and  @joiningDate <> '' AND (UPPER(@CurSample) = UPPER(@JD_Date_Format))
										set @Date_Code =  substring(Convert(varchar(4),Year(@joiningDate)),3,2) + @DayJoiningDate + @MonthJoingDate
								end
							ELSE IF @Date_Format = 'YYMMDD'
								BEGIN
									if @is_JoiningDate_Wise = 1 and  @joiningDate <> '' AND (UPPER(@CurSample) = UPPER(@JD_Date_Format))
										set @Date_Code =  substring(Convert(varchar(4),Year(@joiningDate)),3,2) + @MonthJoingDate + @DayJoiningDate
								end
							ELSE IF @Date_Format = 'YYYYMM'
								BEGIN
									if @is_JoiningDate_Wise = 1 and  @joiningDate <> '' AND (UPPER(@CurSample) = UPPER(@JD_Date_Format))
										set @Date_Code =  CONVERT(varchar(4),Year(@joiningDate)) + @MonthJoingDate
								end
							ELSE IF @Date_Format = 'YYYYMMDD'
								BEGIN
									if @is_JoiningDate_Wise = 1 and  @joiningDate <> '' AND (UPPER(@CurSample) = UPPER(@JD_Date_Format))
										set @Date_Code =  CONVERT(varchar(4),Year(@joiningDate)) + @MonthJoingDate + @DayJoiningDate
								end
							ELSE IF @Date_Format = 'YYYYDDMM'
								BEGIN
									if @is_JoiningDate_Wise = 1 and  @joiningDate <> '' AND (UPPER(@CurSample) = UPPER(@JD_Date_Format))
										set @Date_Code =  CONVERT(varchar(4),Year(@joiningDate))+ @DayJoiningDate + @MonthJoingDate
								END	
							ELSE IF @Date_Format = 'YY'
								BEGIN
									if @is_JoiningDate_Wise = 1 and  @joiningDate <> '' AND (UPPER(@CurSample) =UPPER(@JD_Date_Format))
										set @Date_Code =  substring(Convert(varchar(4),Year(@joiningDate)),3,2) 
								END
							
							
							
							SET @Sample_Code = @Sample_Code + @Date_Code
								
						END
					ELSE IF (UPPER(@CurSample) = UPPER(@BD_Date_Format)) AND @Is_DateOFBirth_Wise = 1 AND @Date_OF_Birth <> '' -- Birth Date 
						BEGIN
							IF DAY(@Date_OF_Birth) < 10
								set @DayDate_OF_Birth = '0' + CONVERT(varchar(2), DAY(@Date_OF_Birth))
							else
								set @DayDate_OF_Birth = CONVERT(varchar(2), DAY(@Date_OF_Birth))
									
							if Month(@Date_OF_Birth) < 10
								set @MonthDate_OF_Birth = '0' + CONVERT(varchar(2),Month(@Date_OF_Birth))
							else
								set  @MonthDate_OF_Birth = CONVERT(varchar(2), Month(@Date_OF_Birth))	
						
							IF  @DateOFBirth_Format = 'DDMM'
								BEGIN
									IF @Is_DateOFBirth_Wise = 1 AND @Date_OF_Birth <> '' AND (UPPER(@CurSample) = UPPER(@BD_Date_Format))
										Set @Date_Code =  @DayDate_OF_Birth + @MonthDate_OF_Birth
								END
							ELSE IF @DateOFBirth_Format = 'DDMMYY'
								BEGIN
									IF @Is_DateOFBirth_Wise = 1 AND @Date_OF_Birth <> '' AND (UPPER(@CurSample) = UPPER(@BD_Date_Format))
										SET @Date_Code =  @DayDate_OF_Birth + @MonthDate_OF_Birth + substring(Convert(varchar(4),Year(@Date_OF_Birth)),3,2)
								end
							ELSE IF @DateOFBirth_Format = 'DDMMYYYY'
								BEGIN
									IF @Is_DateOFBirth_Wise = 1 AND @Date_OF_Birth <> '' AND (UPPER(@CurSample) = UPPER(@BD_Date_Format))
										SET @Date_Code =  @DayDate_OF_Birth + @MonthDate_OF_Birth + CONVERT(varchar(4),Year(@Date_OF_Birth))
								END
							ELSE IF @DateOFBirth_Format = 'MMDD'
								BEGIN
									IF @Is_DateOFBirth_Wise = 1 AND @Date_OF_Birth <> '' AND (UPPER(@CurSample) = UPPER(@BD_Date_Format))
										set @Date_Code =  @MonthDate_OF_Birth + @DayDate_OF_Birth
								END
							ELSE IF @DateOFBirth_Format = 'MMYY'
								BEGIN
									IF @Is_DateOFBirth_Wise = 1 AND @Date_OF_Birth <> '' AND (UPPER(@CurSample) = UPPER(@BD_Date_Format))
										SET @Date_Code =  @MonthDate_OF_Birth + substring(Convert(varchar(4),Year(@Date_OF_Birth)),3,2)
								END	
							ELSE IF @DateOFBirth_Format = 'MMYYYY'
								BEGIN
									IF @Is_DateOFBirth_Wise = 1 AND @Date_OF_Birth <> '' AND (UPPER(@CurSample) = UPPER(@BD_Date_Format))
										SET @Date_Code =  @MonthDate_OF_Birth + convert(varchar(4),Year(@Date_OF_Birth))
								end
							ELSE IF @DateOFBirth_Format = 'MMDDYY'
								BEGIN
									IF @Is_DateOFBirth_Wise = 1 AND @Date_OF_Birth <> '' AND (UPPER(@CurSample) = UPPER(@BD_Date_Format))
										SET @Date_Code =  @MonthDate_OF_Birth + @DayDate_OF_Birth + substring(Convert(varchar(4),Year(@Date_OF_Birth)),3,2)
								end
							ELSE IF @DateOFBirth_Format = 'MMDDYYYY'
								BEGIN
									IF @Is_DateOFBirth_Wise = 1 AND @Date_OF_Birth <> '' AND (UPPER(@CurSample) = UPPER(@BD_Date_Format))
										SET @Date_Code =  @MonthDate_OF_Birth + @DayDate_OF_Birth + Convert(varchar(4),Year(@Date_OF_Birth))
								end
							ELSE IF @DateOFBirth_Format = 'MMYYDD'
								BEGIN
									IF @Is_DateOFBirth_Wise = 1 AND @Date_OF_Birth <> '' AND (UPPER(@CurSample) = UPPER(@BD_Date_Format))
										set @Date_Code =  @MonthDate_OF_Birth + substring(Convert(varchar(4),Year(@Date_OF_Birth)),3,2) + @DayDate_OF_Birth
								end
							ELSE IF @DateOFBirth_Format = 'MMYYYYDD'
								BEGIN
									IF @Is_DateOFBirth_Wise = 1 AND @Date_OF_Birth <> '' AND (UPPER(@CurSample) = UPPER(@BD_Date_Format))
										SET @Date_Code =  @MonthDate_OF_Birth + Convert(varchar(4),Year(@Date_OF_Birth)) + @DayDate_OF_Birth
								end
							ELSE IF @DateOFBirth_Format = 'YYMM'
								BEGIN
									IF @Is_DateOFBirth_Wise = 1 AND @Date_OF_Birth <> '' AND (UPPER(@CurSample) = UPPER(@BD_Date_Format))
										SET @Date_Code =  substring(Convert(varchar(4),Year(@Date_OF_Birth)),3,2) + @MonthDate_OF_Birth
								end
							ELSE IF @DateOFBirth_Format = 'YYDDMM'
								BEGIN
									IF @Is_DateOFBirth_Wise = 1 AND @Date_OF_Birth <> '' AND (UPPER(@CurSample) = UPPER(@BD_Date_Format))
										SET @Date_Code =  substring(Convert(varchar(4),Year(@Date_OF_Birth)),3,2) + @DayDate_OF_Birth + @MonthDate_OF_Birth
								end
							ELSE IF @DateOFBirth_Format = 'YYMMDD'
								BEGIN
									IF @Is_DateOFBirth_Wise = 1 AND @Date_OF_Birth <> '' AND (UPPER(@CurSample) = UPPER(@BD_Date_Format))
										SET @Date_Code =  substring(Convert(varchar(4),Year(@Date_OF_Birth)),3,2) + @MonthDate_OF_Birth + @DayDate_OF_Birth
								end
							ELSE IF @DateOFBirth_Format = 'YYYYMM'
								BEGIN
									IF @Is_DateOFBirth_Wise = 1 AND @Date_OF_Birth <> '' AND (UPPER(@CurSample) = UPPER(@BD_Date_Format))
										SET @Date_Code =  Convert(varchar(4),Year(@Date_OF_Birth)) + @MonthDate_OF_Birth
								end
							ELSE IF @DateOFBirth_Format = 'YYYYMMDD'
								BEGIN
									IF @Is_DateOFBirth_Wise = 1 AND @Date_OF_Birth <> '' AND (UPPER(@CurSample) = UPPER(@BD_Date_Format))
										SET @Date_Code =  CONVERT(varchar(4),Year(@Date_OF_Birth))  + @MonthDate_OF_Birth+  @DayDate_OF_Birth
								end
							ELSE IF @DateOFBirth_Format = 'YYYYDDMM'
								BEGIN
									IF @Is_DateOFBirth_Wise = 1 AND @Date_OF_Birth <> '' AND (UPPER(@CurSample) = UPPER(@BD_Date_Format))
										SET @Date_Code =  convert(varchar(4),Year(@Date_OF_Birth)) + @DayDate_OF_Birth + @MonthDate_OF_Birth
								END	
							ELSE IF @DateOFBirth_Format = 'YY'
								BEGIN
									IF @Is_DateOFBirth_Wise = 1 AND @Date_OF_Birth <> '' AND (UPPER(@CurSample) = UPPER(@BD_Date_Format))
										SET @Date_Code =  substring(Convert(varchar(4),Year(@Date_OF_Birth)),3,2) 
								END
							
							SET @Sample_Code = @Sample_Code + @Date_Code
								
						END
					ELSE IF (UPPER(@CurSample) = UPPER(@CD_Date_Format)) AND @Is_CurrentDate_Wise = 1 -- Current Date Date 
						BEGIN
							IF DAY(GETDATE()) < 10
								set @DayCurrentDate = '0' + CONVERT(varchar(2), DAY(GETDATE()))
							else
								set @DayCurrentDate = Convert(varchar(2),DAY(GETDATE()))
									
							if Month(GETDATE()) < 10
								set @MonthCurrentDate = '0' + CONVERT(varchar(2),Month(GETDATE()))
							else
								set @MonthCurrentDate = Convert(varchar(2),Month(GETDATE()))
								
									
							IF @CurrentDate_Format = 'DDMM'
								BEGIN
									if @Is_CurrentDate_Wise = 1 AND (UPPER(@CurSample) = UPPER(@CD_Date_Format))
										set @Date_Code =  @DayCurrentDate + @MonthCurrentDate
								END
							ELSE IF @CurrentDate_Format = 'DDMMYY'
								BEGIN
									IF @Is_CurrentDate_Wise = 1 AND (UPPER(@CurSample) = UPPER(@CD_Date_Format))
										set @Date_Code =  @DayCurrentDate + @MonthCurrentDate + substring(Convert(varchar(4),Year(GETDATE())),3,2)
								end
							ELSE IF @CurrentDate_Format = 'DDMMYYYY'
								BEGIN
									if @Is_CurrentDate_Wise = 1 AND (UPPER(@CurSample) = UPPER(@CD_Date_Format))	 
										set @Date_Code =  @DayCurrentDate + @MonthCurrentDate + CONVERT(varchar(4),Year(GETDATE()))
								END
							ELSE IF @CurrentDate_Format = 'MMDD'
								BEGIN
									IF @Is_CurrentDate_Wise = 1 AND (UPPER(@CurSample) = UPPER(@CD_Date_Format))	 	 
										set @Date_Code =  @MonthCurrentDate  + @DayCurrentDate
								END
							ELSE IF @CurrentDate_Format = 'MMYY'
								BEGIN
									if @Is_CurrentDate_Wise = 1 AND (UPPER(@CurSample) = UPPER(@CD_Date_Format))	 	 	 
										set @Date_Code =  @MonthCurrentDate + substring(Convert(varchar(4),Year(GETDATE())),3,2)
								END	
							ELSE IF @CurrentDate_Format = 'MMYYYY'
								BEGIN
									if @Is_CurrentDate_Wise = 1 AND (UPPER(@CurSample) = UPPER(@CD_Date_Format))	 	 	 	 
										set @Date_Code =  @MonthCurrentDate + convert(varchar(4),Year(GETDATE()))
								end
							ELSE IF @CurrentDate_Format = 'MMDDYY'
								BEGIN
									if @Is_CurrentDate_Wise = 1 AND (UPPER(@CurSample) = UPPER(@CD_Date_Format))
										set @Date_Code =  @MonthCurrentDate + @DayCurrentDate + substring(Convert(varchar(4),Year(GETDATE())),3,2)
								end
							ELSE IF @CurrentDate_Format = 'MMDDYYYY'
								BEGIN
									if @Is_CurrentDate_Wise = 1 AND (UPPER(@CurSample) = UPPER(@CD_Date_Format))	 
										set @Date_Code =  @MonthCurrentDate + @DayCurrentDate + Convert(varchar(4),Year(GETDATE()))
								end
							ELSE IF @CurrentDate_Format = 'MMYYDD'
								BEGIN
									if @Is_CurrentDate_Wise = 1 AND (UPPER(@CurSample) = UPPER(@CD_Date_Format))	 	 
										set @Date_Code =  @MonthCurrentDate + substring(Convert(varchar(4),Year(GETDATE())),3,2) + @DayCurrentDate
								end
							ELSE IF @CurrentDate_Format = 'MMYYYYDD'
								BEGIN
									if @Is_CurrentDate_Wise = 1 AND (UPPER(@CurSample) = UPPER(@CD_Date_Format))	 	 	 
										set @Date_Code =  @MonthCurrentDate + Convert(varchar(4),Year(GETDATE())) + @DayCurrentDate
								end
							ELSE IF @CurrentDate_Format = 'YYMM'
								BEGIN
									if @Is_CurrentDate_Wise = 1 AND (UPPER(@CurSample) = UPPER(@CD_Date_Format))	 	 	 	 
										set @Date_Code =  substring(Convert(varchar(4),Year(GETDATE())),3,2) + @MonthCurrentDate
								end
							ELSE IF @CurrentDate_Format = 'YYDDMM'
								BEGIN
									if @Is_CurrentDate_Wise = 1 AND (UPPER(@CurSample) = UPPER(@CD_Date_Format))	 
										set @Date_Code =  substring(Convert(varchar(4),Year(GETDATE())),3,2) + @DayCurrentDate + @MonthCurrentDate
								end
							ELSE IF @CurrentDate_Format = 'YYMMDD'
								BEGIN
									if @Is_CurrentDate_Wise = 1 AND (UPPER(@CurSample) = UPPER(@CD_Date_Format)) 
										set @Date_Code =  substring(Convert(varchar(4),Year(GETDATE())),3,2) + @MonthCurrentDate + @DayCurrentDate
								end
							ELSE IF @CurrentDate_Format = 'YYYYMM'
								BEGIN
									if @Is_CurrentDate_Wise = 1 AND (UPPER(@CurSample) = UPPER(@CD_Date_Format))	 
										set @Date_Code =  Convert(varchar(4),Year(GETDATE())) + @MonthCurrentDate
								end
							ELSE IF @CurrentDate_Format = 'YYYYMMDD'
								BEGIN
									if @Is_CurrentDate_Wise = 1 AND (UPPER(@CurSample) = UPPER(@CD_Date_Format))	 
										set @Date_Code =  CONVERT(varchar(4),Year(GETDATE()))  + @MonthCurrentDate+  @DayCurrentDate
								end
							ELSE IF @CurrentDate_Format = 'YYYYDDMM'
								BEGIN
									if @Is_CurrentDate_Wise = 1 AND (UPPER(@CurSample) = UPPER(@CD_Date_Format))	 
										set @Date_Code =  convert(varchar(4),Year(GETDATE())) + @DayCurrentDate + @MonthCurrentDate
								END	
							ELSE IF @CurrentDate_Format = 'YY'
								BEGIN
									if @Is_CurrentDate_Wise = 1 AND (UPPER(@CurSample) = UPPER(@CD_Date_Format))	 
										set @Date_Code =  substring(Convert(varchar(4),Year(GETDATE())),3,2) 
								END
							
							
							
							SET @Sample_Code = @Sample_Code + @Date_Code
								
						END
					ELSE IF @CurSample = '-'
						BEGIN
							SET @Sample_Code = @Sample_Code + '-'
						END
						
			
					FETCH NEXT FROM CusrSample into @CurSample
				END
			close CusrSample         
			deallocate CusrSample

	END
set @Date_Code = ''
	Declare @len as numeric
	
	

	if @Is_Date_Wise = 1  and @Is_Only_Emp_Code = 0
		begin
		
			IF @Max_Emp_Code = 'Company_Wise'
				Begin
					
					set @Emp_Code = @Date_Code	
						If @Is_Alpha_Numeric_Branchwise = 1  and @Is_Alpha_Numeric_Companywise = 1
							begin
								if @is_ResetSequance = 1 
									begin
										if @Branch_Id > 0 
											begin
													if @is_JoiningDate_Wise = 1
														begin
															if isdate(@joiningDate) = 1 
																begin
																	select @Emp_Code = max(Emp_Code) from
																	(Select CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) as Emp_Code from T0080_EMP_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_Id and Branch_ID=@Branch_Id  
																	and  SUBSTRING(isnull(Code_Date,Convert(varchar(20),00)), PATINDEX('%MM%',isnull(Code_Date_Format,'MM')),2)  = Month(@joiningDate)
																	and  Year(System_Date) = Year(@joiningDate)	
																	union all
																	Select  CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) as Emp_Code from T0060_EMP_MASTER_APP WITH (NOLOCK) where Cmp_ID=@Cmp_Id and Branch_ID=@Branch_Id  
																	and  SUBSTRING(isnull(Code_Date,Convert(varchar(20),00)), PATINDEX('%MM%',isnull(Code_Date_Format,'MM')),2)  = Month(@joiningDate)
																	and  Year(System_Date) = Year(@joiningDate)	)t
																end
															else
																begin
																select @Emp_Code = max(Emp_Code) from
																	(
																	Select  CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) as Emp_Code from T0080_EMP_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_Id and Branch_ID=@Branch_Id  
																	union all
																	Select  CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) as Emp_Code from T0060_EMP_MASTER_APP WITH (NOLOCK) where Cmp_ID=@Cmp_Id and Branch_ID=@Branch_Id  
																	)t
																end
														end
													else
														begin
															select @Emp_Code = max(Emp_Code) from
															(Select  CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) as Emp_Code from T0080_EMP_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_Id and Branch_ID=@Branch_Id  
																and  SUBSTRING(isnull(Code_Date,Convert(varchar(20),00)), PATINDEX('%MM%',isnull(Code_Date_Format,'MM')),2)  = Month(GETDATE())
																and  Year(System_Date) = Year(GETDATE())																
																union all																
																Select  CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) as Emp_Code from T0060_EMP_MASTER_APP WITH (NOLOCK) where Cmp_ID=@Cmp_Id and Branch_ID=@Branch_Id  
																and  SUBSTRING(isnull(Code_Date,Convert(varchar(20),00)), PATINDEX('%MM%',isnull(Code_Date_Format,'MM')),2)  = Month(GETDATE())
																and  Year(System_Date) = Year(GETDATE())															
															)t
														end
														
													set @len = LEN(CAST (@emp_code as varchar(10)))
													
													if @len > @No_Of_Digits
														set @len = @No_Of_Digits
														
													set @Emp_Code = @Date_Code + REPLICATE ('0',@No_Of_Digits - @len) + @Emp_Code
													
													
											end
										else
											begin
												if @is_JoiningDate_Wise = 1
													begin
													
														if isdate(@joiningDate) = 1 
																begin
																	select @Emp_Code = max(Emp_Code) from
																 (
																	Select CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) as Emp_Code from T0080_EMP_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_Id  
																	and  SUBSTRING(isnull(Code_Date,Convert(varchar(20),00)), PATINDEX('%MM%',isnull(Code_Date_Format,'MM')),2)  = Month(@joiningDate)
																	and  Year(System_Date) = Year(@joiningDate)	
																	union all																	
																	Select CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) as Emp_Code from T0060_EMP_MASTER_APP WITH (NOLOCK) where Cmp_ID=@Cmp_Id  
																	and  SUBSTRING(isnull(Code_Date,Convert(varchar(20),00)), PATINDEX('%MM%',isnull(Code_Date_Format,'MM')),2)  = Month(@joiningDate)
																	and  Year(System_Date) = Year(@joiningDate)	
																	
																)t
																end
															else
																begin
																	select @Emp_Code = max(Emp_Code) from
																 (
																	Select CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) as Emp_Code from T0080_EMP_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_Id   
																	union all	
																	Select CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) as Emp_Code from T0060_EMP_MASTER_APP WITH (NOLOCK) where Cmp_ID=@Cmp_Id   
																  )t
																end
													end
												else
													begin
													select @Emp_Code = max(Emp_Code) from
													(
														Select CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) as Emp_Code from T0080_EMP_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_Id 
														and  SUBSTRING(isnull(Code_Date,Convert(varchar(20),00)), PATINDEX('%MM%',isnull(Code_Date_Format,'MM')),2)  = Month(GETDATE())		
														and  Year(System_Date) = Year(GETDATE())
														union all
														Select CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) as Emp_Code from T0060_EMP_MASTER_APP WITH (NOLOCK) where Cmp_ID=@Cmp_Id 
														and  SUBSTRING(isnull(Code_Date,Convert(varchar(20),00)), PATINDEX('%MM%',isnull(Code_Date_Format,'MM')),2)  = Month(GETDATE())		
														and  Year(System_Date) = Year(GETDATE())
												    )t
													end	
													set @len = LEN(CAST (@emp_code as varchar(10)))
													
													if @len > @No_Of_Digits
														set @len = @No_Of_Digits
														
													set @Emp_Code = @Date_Code + REPLICATE ('0',@No_Of_Digits - @len) + @Emp_Code
			
											end 
									end
								else
									begin
										if @Branch_Id > 0 
											begin
													select @Emp_Code = max(Emp_Code) from
												(
													Select CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) as Emp_Code from T0080_EMP_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_Id and Branch_ID=@Branch_Id  
													union all
													Select CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) as Emp_Code from T0060_EMP_MASTER_APP WITH (NOLOCK) where Cmp_ID=@Cmp_Id and Branch_ID=@Branch_Id  
												 )t
												set @len = LEN(CAST (@emp_code as varchar(10)))
													
													if @len > @No_Of_Digits
														set @len = @No_Of_Digits
														
													set @Emp_Code = @Date_Code + REPLICATE ('0',@No_Of_Digits - @len) + @Emp_Code
											end	
										else
											begin
												select @Emp_Code = max(Emp_Code) from
												(
													Select CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) as Emp_Code from T0080_EMP_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_Id 
													union all
													Select CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) as Emp_Code from T0060_EMP_MASTER_APP WITH (NOLOCK) where Cmp_ID=@Cmp_Id 
												
												 )t
												set @len = LEN(CAST (@emp_code as varchar(10)))
													
													if @len > @No_Of_Digits
														set @len = @No_Of_Digits
													
													set @Emp_Code = @Date_Code + REPLICATE ('0',@No_Of_Digits - @len) + @Emp_Code
										
											end
										end
							end
						else if @Is_Alpha_Numeric_Branchwise = 1  and @Is_Alpha_Numeric_Companywise = 0
							begin
								if @is_ResetSequance = 1 
									begin
										if @Branch_Id > 0
											begin 
												if @is_JoiningDate_Wise = 1
													begin
													if isdate(@joiningDate) = 1  
														begin
														
															select @Emp_Code = max(Emp_Code) from
															(
																Select CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) as Emp_Code from T0080_EMP_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_Id and Branch_ID=@Branch_Id 
																and  SUBSTRING(isnull(Code_Date,Convert(varchar(20),00)), PATINDEX('%MM%',isnull(Code_Date_Format,'MM')),2)  = Month(@joiningDate)		
																and  Year(System_Date) = Year(@joiningDate)
																union all
																Select CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) as Emp_Code from T0060_EMP_MASTER_APP WITH (NOLOCK) where Cmp_ID=@Cmp_Id and Branch_ID=@Branch_Id 
																and  SUBSTRING(isnull(Code_Date,Convert(varchar(20),00)), PATINDEX('%MM%',isnull(Code_Date_Format,'MM')),2)  = Month(@joiningDate)		
																and  Year(System_Date) = Year(@joiningDate)
															)t
														end
													else
														begin
															select @Emp_Code = max(Emp_Code) from
															(
															Select CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) as Emp_Code from T0080_EMP_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_Id and Branch_ID=@Branch_Id 
															union all
															Select CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) as Emp_Code from T0060_EMP_MASTER_APP WITH (NOLOCK) where Cmp_ID=@Cmp_Id and Branch_ID=@Branch_Id 
															)t
														end
													end
												else
													begin
													select @Emp_Code = max(Emp_Code) from
															(
														Select CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) as Emp_Code from T0080_EMP_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_Id and Branch_ID=@Branch_Id 
														and  SUBSTRING(isnull(Code_Date,Convert(varchar(20),00)), PATINDEX('%MM%',isnull(Code_Date_Format,'MM')),2)  = Month(GETDATE())		
														and  Year(System_Date) = Year(GETDATE())	
														union all														
														Select CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) as Emp_Code from T0060_EMP_MASTER_APP WITH (NOLOCK) where Cmp_ID=@Cmp_Id and Branch_ID=@Branch_Id 
														and  SUBSTRING(isnull(Code_Date,Convert(varchar(20),00)), PATINDEX('%MM%',isnull(Code_Date_Format,'MM')),2)  = Month(GETDATE())		
														and  Year(System_Date) = Year(GETDATE())
															)t
													end
														set @len = LEN(CAST (@emp_code as varchar(10)))
													
														if @len > @No_Of_Digits
															set @len = @No_Of_Digits
														
														set @Emp_Code = @Date_Code + REPLICATE ('0',@No_Of_Digits - @len) + @Emp_Code
													
											end
										else	
											begin
											if @is_JoiningDate_Wise = 1
												begin
													if isdate(@joiningDate) = 1  
														begin
															select @Emp_Code = max(Emp_Code) from
															(
																Select CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) as Emp_Code from T0080_EMP_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_Id  
																and  SUBSTRING(isnull(Code_Date,Convert(varchar(20),00)), PATINDEX('%MM%',isnull(Code_Date_Format,'MM')),2)  = 	Month(@joiningDate)		
																and  Year(System_Date) = Year(@joiningDate)
																union all
																Select CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) as Emp_Code from T0060_EMP_MASTER_APP WITH (NOLOCK) where Cmp_ID=@Cmp_Id  
																and  SUBSTRING(isnull(Code_Date,Convert(varchar(20),00)), PATINDEX('%MM%',isnull(Code_Date_Format,'MM')),2)  = 	Month(@joiningDate)		
																and  Year(System_Date) = Year(@joiningDate)															
															)t
														end
													else
														Begin
																select @Emp_Code = max(Emp_Code) from
														(
															Select CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) as Emp_Code from T0080_EMP_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_Id  
															union all
															Select CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) as Emp_Code from T0060_EMP_MASTER_APP WITH (NOLOCK) where Cmp_ID=@Cmp_Id  
														)t
														end	
														
												end
											else
												begin
													select @Emp_Code = max(Emp_Code) from
												(
													Select CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) as Emp_Code from T0080_EMP_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_Id  
													and  SUBSTRING(isnull(Code_Date,Convert(varchar(20),00)), PATINDEX('%MM%',isnull(Code_Date_Format,'MM')),2)  = Month(GETDATE())		
													and  Year(System_Date) = Year(GETDATE())
													union all
													Select CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) as Emp_Code from T0060_EMP_MASTER_APP WITH (NOLOCK) where Cmp_ID=@Cmp_Id  
													and  SUBSTRING(isnull(Code_Date,Convert(varchar(20),00)), PATINDEX('%MM%',isnull(Code_Date_Format,'MM')),2)  = Month(GETDATE())		
													and  Year(System_Date) = Year(GETDATE())
													
												)t
												end
													set @len = LEN(CAST (@emp_code as varchar(10)))
													
														if @len > @No_Of_Digits
															set @len = @No_Of_Digits
														
														set @Emp_Code = @Date_Code + REPLICATE ('0',@No_Of_Digits - @len) + @Emp_Code
												
											end
									end
								else
									begin
										if @Branch_Id > 0 
											begin
											select @Emp_Code = max(Emp_Code) from
												(
												Select CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) as Emp_Code from T0080_EMP_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_Id and Branch_ID=@Branch_Id		
												union all
												Select CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) as Emp_Code from T0060_EMP_MASTER_APP WITH (NOLOCK) where Cmp_ID=@Cmp_Id and Branch_ID=@Branch_Id		
												)t
												
												set @len = LEN(CAST (@emp_code as varchar(10)))
													
													if @len > @No_Of_Digits
														set @len = @No_Of_Digits
														
													set @Emp_Code = @Date_Code + REPLICATE ('0',@No_Of_Digits - @len) + @Emp_Code
											end	
										else
											begin
													select @Emp_Code = max(Emp_Code) from
												(
												Select CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) as Emp_Code from T0080_EMP_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_Id 		
												union all
												Select CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) as Emp_Code from T0060_EMP_MASTER_APP WITH (NOLOCK) where Cmp_ID=@Cmp_Id 		
												)t
												set @len = LEN(CAST (@emp_code as varchar(10)))
													
													if @len > @No_Of_Digits
														set @len = @No_Of_Digits
														
													set @Emp_Code = @Date_Code + REPLICATE ('0',@No_Of_Digits - @len) + @Emp_Code
											end
									end
							end
					    else if (@Is_Alpha_Numeric_Branchwise = 0  and @Is_Alpha_Numeric_Companywise = 1 ) or ( @Is_Alpha_Numeric_Branchwise = 0 and @Is_Alpha_Numeric_Companywise = 0)
							begin
								if @is_ResetSequance = 1 
									begin
									if @is_JoiningDate_Wise = 1
										begin
											if isdate(@joiningDate) = 1 
												begin
													select @Emp_Code = max(Emp_Code) from
												(
													Select CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) as Emp_Code from T0080_EMP_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_Id	
													and SUBSTRING(isnull(Code_Date,Convert(varchar(20),00)), PATINDEX('%MM%',isnull(Code_Date_Format,'MM')),2)  = Month(@joiningDate)
													and  Year(System_Date) = Year(@joiningDate)
													union all
													Select CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) as Emp_Code from T0060_EMP_MASTER_APP WITH (NOLOCK) where Cmp_ID=@Cmp_Id	
													and SUBSTRING(isnull(Code_Date,Convert(varchar(20),00)), PATINDEX('%MM%',isnull(Code_Date_Format,'MM')),2)  = Month(@joiningDate)
													and  Year(System_Date) = Year(@joiningDate)
												)t
												end
											else
												begin
													select @Emp_Code = max(Emp_Code) from
												(
													Select CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1)as Emp_Code from T0080_EMP_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_Id	
													union all
													Select CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1)as Emp_Code from T0060_EMP_MASTER_APP WITH (NOLOCK) where Cmp_ID=@Cmp_Id	
												)t
												end
										end
									else
										begin
											select @Emp_Code = max(Emp_Code) from
												(
											Select CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) as Emp_Code from T0080_EMP_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_Id	
											and SUBSTRING(isnull(Code_Date,Convert(varchar(20),00)), PATINDEX('%MM%',isnull(Code_Date_Format,'MM')),2)  = Month(GETDATE())
											and  Year(System_Date) = Year(GETDATE())
											union all
											Select CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) as Emp_Code from T0060_EMP_MASTER_APP WITH (NOLOCK) where Cmp_ID=@Cmp_Id	
											and SUBSTRING(isnull(Code_Date,Convert(varchar(20),00)), PATINDEX('%MM%',isnull(Code_Date_Format,'MM')),2)  = Month(GETDATE())
											and  Year(System_Date) = Year(GETDATE())
											)t
										end
												set @len = LEN(CAST (@emp_code as varchar(10)))
													
													if @len > @No_Of_Digits
														set @len = @No_Of_Digits
														
													set @Emp_Code = @Date_Code + REPLICATE ('0',@No_Of_Digits - @len) + @Emp_Code
									end
								else
									begin
										select @Emp_Code = max(Emp_Code) from
												(
										Select CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) as Emp_Code from T0080_EMP_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_Id	
										union all
										Select CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) as Emp_Code from T0060_EMP_MASTER_APP WITH (NOLOCK) where Cmp_ID=@Cmp_Id
										)t
										set @len = LEN(CAST (@emp_code as varchar(10)))
													
													if @len > @No_Of_Digits
														set @len = @No_Of_Digits
														
													set @Emp_Code = @Date_Code + REPLICATE ('0',@No_Of_Digits - @len) + @Emp_Code
									end	
							end
				End
			Else If @Max_Emp_Code = 'Group_Company_Wise'
				Begin
					
					set @Emp_Code = @Date_Code	
						If @Is_Alpha_Numeric_Branchwise = 1  and @Is_Alpha_Numeric_Companywise = 1
							begin
							
								if @is_ResetSequance = 1 
									begin
									
										if @Branch_Id < 0 
											begin
												if @is_JoiningDate_Wise = 1
													begin
													
														if isdate(@joiningDate) = 1 
															begin
																select @Emp_Code = max(Emp_Code) from
															(
																Select CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) as Emp_Code from T0080_EMP_MASTER WITH (NOLOCK)
																Where Cmp_ID In (Select Cmp_ID From T0010_COMPANY_MASTER WITH (NOLOCK) Where is_GroupOFCmp = 1 And Max_Emp_Code = @Max_Emp_Code )											
																and  SUBSTRING(isnull(Code_Date,Convert(varchar(20),00)), PATINDEX('%MM%',isnull(Code_Date_Format,'MM')),2)  = Month(@joiningDate)
																and  Year(System_Date) = Year(@joiningDate)	
																union all
																Select CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) as Emp_Code from T0060_EMP_MASTER_APP WITH (NOLOCK)
																Where Cmp_ID In (Select Cmp_ID From T0010_COMPANY_MASTER WITH (NOLOCK) Where is_GroupOFCmp = 1 And Max_Emp_Code = @Max_Emp_Code )											
																and  SUBSTRING(isnull(Code_Date,Convert(varchar(20),00)), PATINDEX('%MM%',isnull(Code_Date_Format,'MM')),2)  = Month(@joiningDate)
																and  Year(System_Date) = Year(@joiningDate)
																
																)t
															end
														else
															begin
																select @Emp_Code = max(Emp_Code) from
															(
																Select CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) as Emp_Code from T0080_EMP_MASTER WITH (NOLOCK)
																Where Cmp_ID In (Select Cmp_ID From T0010_COMPANY_MASTER WITH (NOLOCK) Where is_GroupOFCmp = 1 And Max_Emp_Code = @Max_Emp_Code )
																union all
																Select CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) as Emp_Code from T0060_EMP_MASTER_APP WITH (NOLOCK)
																Where Cmp_ID In (Select Cmp_ID From T0010_COMPANY_MASTER WITH (NOLOCK) Where is_GroupOFCmp = 1 And Max_Emp_Code = @Max_Emp_Code )
																
															)t
															end
													end
												else
													begin
													
														select @Emp_Code = max(Emp_Code) from
															(
														Select CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) as Emp_Code from T0080_EMP_MASTER WITH (NOLOCK)
														Where Cmp_ID In (Select Cmp_ID From T0010_COMPANY_MASTER WITH (NOLOCK) Where is_GroupOFCmp = 1 And Max_Emp_Code = @Max_Emp_Code )												
														and  SUBSTRING(isnull(Code_Date,Convert(varchar(20),00)), PATINDEX('%MM%',isnull(Code_Date_Format,'MM')),2)  = Month(GETDATE())		
														and  Year(System_Date) = Year(GETDATE())
														union all
														Select CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) as Emp_Code from T0060_EMP_MASTER_APP WITH (NOLOCK)
														Where Cmp_ID In (Select Cmp_ID From T0010_COMPANY_MASTER WITH (NOLOCK) Where is_GroupOFCmp = 1 And Max_Emp_Code = @Max_Emp_Code )												
														and  SUBSTRING(isnull(Code_Date,Convert(varchar(20),00)), PATINDEX('%MM%',isnull(Code_Date_Format,'MM')),2)  = Month(GETDATE())		
														and  Year(System_Date) = Year(GETDATE())
														)t
													end	
													set @len = LEN(CAST (@emp_code as varchar(10)))
													
													if @len > @No_Of_Digits
														set @len = @No_Of_Digits
														
													set @Emp_Code = @Date_Code + REPLICATE ('0',@No_Of_Digits - @len) + @Emp_Code
			
											end 
										else
											begin
											
											if @is_JoiningDate_Wise = 1
													begin
													
														if isdate(@joiningDate) = 1 
																begin
																	select @Emp_Code = max(Emp_Code) from
																(
																	Select CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) as Emp_Code from T0080_EMP_MASTER WITH (NOLOCK) where Cmp_ID In (Select Cmp_ID From T0010_COMPANY_MASTER WITH (NOLOCK) Where is_GroupOFCmp = 1 And Max_Emp_Code = @Max_Emp_Code ) 
																	and  SUBSTRING(isnull(Code_Date,Convert(varchar(20),00)), PATINDEX('%MM%',isnull(Code_Date_Format,'MM')),2)  = Month(@joiningDate)
																	and  Year(System_Date) = Year(@joiningDate)	
																	union all
																	Select CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) as Emp_Code from T0060_EMP_MASTER_APP WITH (NOLOCK) where Cmp_ID In (Select Cmp_ID From T0010_COMPANY_MASTER WITH (NOLOCK) Where is_GroupOFCmp = 1 And Max_Emp_Code = @Max_Emp_Code ) 
																	and  SUBSTRING(isnull(Code_Date,Convert(varchar(20),00)), PATINDEX('%MM%',isnull(Code_Date_Format,'MM')),2)  = Month(@joiningDate)
																	and  Year(System_Date) = Year(@joiningDate)
																	
																	)t
																end
															else
																begin
																
																		select @Emp_Code = max(Emp_Code) from
																(
																	Select CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) as Emp_Code from T0080_EMP_MASTER WITH (NOLOCK) where Cmp_ID In (Select Cmp_ID From T0010_COMPANY_MASTER WITH (NOLOCK) Where is_GroupOFCmp = 1 And Max_Emp_Code = @Max_Emp_Code )   
																	union all
																	Select CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) as Emp_Code from T0060_EMP_MASTER_APP WITH (NOLOCK) where Cmp_ID In (Select Cmp_ID From T0010_COMPANY_MASTER WITH (NOLOCK) Where is_GroupOFCmp = 1 And Max_Emp_Code = @Max_Emp_Code )   
																)t
																end
													end
												else
													begin
													
															select @Emp_Code = max(Emp_Code) from
													(
														Select CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) as Emp_Code from T0080_EMP_MASTER WITH (NOLOCK) where Cmp_ID In (Select Cmp_ID From T0010_COMPANY_MASTER WITH (NOLOCK) Where is_GroupOFCmp = 1 And Max_Emp_Code = @Max_Emp_Code ) 
														and  SUBSTRING(isnull(Code_Date,Convert(varchar(20),00)), PATINDEX('%MM%',isnull(Code_Date_Format,'MM')),2)  = Month(GETDATE())		
														and  Year(System_Date) = Year(GETDATE())
														union all
														Select CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) as Emp_Code from T0060_EMP_MASTER_APP WITH (NOLOCK) where Cmp_ID In (Select Cmp_ID From T0010_COMPANY_MASTER WITH (NOLOCK) Where is_GroupOFCmp = 1 And Max_Emp_Code = @Max_Emp_Code ) 
														and  SUBSTRING(isnull(Code_Date,Convert(varchar(20),00)), PATINDEX('%MM%',isnull(Code_Date_Format,'MM')),2)  = Month(GETDATE())		
														and  Year(System_Date) = Year(GETDATE())
													)t
													end	
													set @len = LEN(CAST (@emp_code as varchar(10)))
													
													if @len > @No_Of_Digits
														set @len = @No_Of_Digits
														
													set @Emp_Code = @Date_Code + REPLICATE ('0',@No_Of_Digits - @len) + @Emp_Code
											end
									  end
								else
									begin
										if @Branch_Id < 0 
											begin
												select @Emp_Code = max(Emp_Code) from
												(
													Select CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) as Emp_Code from T0080_EMP_MASTER WITH (NOLOCK)
													Where Cmp_ID In (Select Cmp_ID From T0010_COMPANY_MASTER WITH (NOLOCK) Where is_GroupOFCmp = 1 And Max_Emp_Code = @Max_Emp_Code )
													union all
													Select CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) as Emp_Code from T0060_EMP_MASTER_APP WITH (NOLOCK)
													Where Cmp_ID In (Select Cmp_ID From T0010_COMPANY_MASTER WITH (NOLOCK) Where is_GroupOFCmp = 1 And Max_Emp_Code = @Max_Emp_Code )
												)t
												set @len = LEN(CAST (@emp_code as varchar(10)))
													
													if @len > @No_Of_Digits
														set @len = @No_Of_Digits
													
													set @Emp_Code = @Date_Code + REPLICATE ('0',@No_Of_Digits - @len) + @Emp_Code
										
											end
										else
											begin
											select @Emp_Code = max(Emp_Code) from
												(
												Select CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) as Emp_Code from T0080_EMP_MASTER WITH (NOLOCK) where Cmp_ID In (Select Cmp_ID From T0010_COMPANY_MASTER WITH (NOLOCK) Where is_GroupOFCmp = 1 And Max_Emp_Code = @Max_Emp_Code )
												union all
												Select CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) as Emp_Code from T0060_EMP_MASTER_APP WITH (NOLOCK) where Cmp_ID In (Select Cmp_ID From T0010_COMPANY_MASTER WITH (NOLOCK) Where is_GroupOFCmp = 1 And Max_Emp_Code = @Max_Emp_Code )
												)t
												set @len = LEN(CAST (@emp_code as varchar(10)))
													
													if @len > @No_Of_Digits
														set @len = @No_Of_Digits
													
													set @Emp_Code = @Date_Code + REPLICATE ('0',@No_Of_Digits - @len) + @Emp_Code
										
											end
											
										end
							end
						else if @Is_Alpha_Numeric_Branchwise = 1  and @Is_Alpha_Numeric_Companywise = 0
							begin
								if @is_ResetSequance = 1 
									begin
										If @Branch_Id < 0
											begin
												if @is_JoiningDate_Wise = 1
													begin
														if isdate(@joiningDate) = 1  
															begin
																	select @Emp_Code = max(Emp_Code) from
															(
																Select CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) as Emp_Code from T0080_EMP_MASTER WITH (NOLOCK)
																Where Cmp_ID In (Select Cmp_ID From T0010_COMPANY_MASTER WITH (NOLOCK) Where is_GroupOFCmp = 1 And Max_Emp_Code = @Max_Emp_Code )
																and  SUBSTRING(isnull(Code_Date,Convert(varchar(20),00)), PATINDEX('%MM%',isnull(Code_Date_Format,'MM')),2)  = 	Month(@joiningDate)		
																and  Year(System_Date) = Year(@joiningDate)
																union all
																Select CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) as Emp_Code from T0060_EMP_MASTER_APP WITH (NOLOCK)
																Where Cmp_ID In (Select Cmp_ID From T0010_COMPANY_MASTER WITH (NOLOCK) Where is_GroupOFCmp = 1 And Max_Emp_Code = @Max_Emp_Code )
																and  SUBSTRING(isnull(Code_Date,Convert(varchar(20),00)), PATINDEX('%MM%',isnull(Code_Date_Format,'MM')),2)  = 	Month(@joiningDate)		
																and  Year(System_Date) = Year(@joiningDate)
														     ) t
															end
														else
															Begin
																select @Emp_Code = max(Emp_Code) from
															(
																Select CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) as Emp_Code from T0080_EMP_MASTER WITH (NOLOCK)
																Where Cmp_ID In (Select Cmp_ID From T0010_COMPANY_MASTER WITH (NOLOCK) Where is_GroupOFCmp = 1 And Max_Emp_Code = @Max_Emp_Code )
																union all
																Select CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) as Emp_Code from T0060_EMP_MASTER_APP WITH (NOLOCK)
																Where Cmp_ID In (Select Cmp_ID From T0010_COMPANY_MASTER WITH (NOLOCK) Where is_GroupOFCmp = 1 And Max_Emp_Code = @Max_Emp_Code )
																
															) t
															end	
															
													end
												else
													begin
													select @Emp_Code = max(Emp_Code) from
															(
														Select CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) as Emp_Code from T0080_EMP_MASTER WITH (NOLOCK) 
														Where Cmp_ID In (Select Cmp_ID From T0010_COMPANY_MASTER WITH (NOLOCK) Where is_GroupOFCmp = 1 And Max_Emp_Code = @Max_Emp_Code )
														and  SUBSTRING(isnull(Code_Date,Convert(varchar(20),00)), PATINDEX('%MM%',isnull(Code_Date_Format,'MM')),2)  = Month(GETDATE())		
														and  Year(System_Date) = Year(GETDATE())
														union all
														Select CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) as Emp_Code from T0060_EMP_MASTER_APP  WITH (NOLOCK)
														Where Cmp_ID In (Select Cmp_ID From T0010_COMPANY_MASTER WITH (NOLOCK) Where is_GroupOFCmp = 1 And Max_Emp_Code = @Max_Emp_Code )
														and  SUBSTRING(isnull(Code_Date,Convert(varchar(20),00)), PATINDEX('%MM%',isnull(Code_Date_Format,'MM')),2)  = Month(GETDATE())		
														and  Year(System_Date) = Year(GETDATE())
														
														
														) t
													end
														set @len = LEN(CAST (@emp_code as varchar(10)))
														
															if @len > @No_Of_Digits
																set @len = @No_Of_Digits
															
															set @Emp_Code = @Date_Code + REPLICATE ('0',@No_Of_Digits - @len) + @Emp_Code
												
											end
										else	
											begin
											if @is_JoiningDate_Wise = 1
												begin
													if isdate(@joiningDate) = 1  
														begin
														select @Emp_Code = max(Emp_Code) from
															(
															Select CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) as Emp_Code from T0080_EMP_MASTER WITH (NOLOCK) where Cmp_ID In (Select Cmp_ID From T0010_COMPANY_MASTER WITH (NOLOCK) Where is_GroupOFCmp = 1 And Max_Emp_Code = @Max_Emp_Code ) 
															and  SUBSTRING(isnull(Code_Date,Convert(varchar(20),00)), PATINDEX('%MM%',isnull(Code_Date_Format,'MM')),2)  = 	Month(@joiningDate)		
															and  Year(System_Date) = Year(@joiningDate)
															union all
															Select CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) as Emp_Code from T0060_EMP_MASTER_APP WITH (NOLOCK) where Cmp_ID In (Select Cmp_ID From T0010_COMPANY_MASTER WITH (NOLOCK) Where is_GroupOFCmp = 1 And Max_Emp_Code = @Max_Emp_Code ) 
															and  SUBSTRING(isnull(Code_Date,Convert(varchar(20),00)), PATINDEX('%MM%',isnull(Code_Date_Format,'MM')),2)  = 	Month(@joiningDate)		
															and  Year(System_Date) = Year(@joiningDate)
															
															)t
														end
													else
														Begin
														select @Emp_Code = max(Emp_Code) from
															(
															Select CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) as Emp_Code from T0080_EMP_MASTER WITH (NOLOCK) where Cmp_ID In (Select Cmp_ID From T0010_COMPANY_MASTER WITH (NOLOCK) Where is_GroupOFCmp = 1 And Max_Emp_Code = @Max_Emp_Code ) 
															union all
															Select CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) as Emp_Code from T0060_EMP_MASTER_APP WITH (NOLOCK) where Cmp_ID In (Select Cmp_ID From T0010_COMPANY_MASTER WITH (NOLOCK) Where is_GroupOFCmp = 1 And Max_Emp_Code = @Max_Emp_Code ) 
															)t
														end	
														
												end
											else
												begin
												select @Emp_Code = max(Emp_Code) from
															(
													Select CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) as Emp_Code from T0080_EMP_MASTER WITH (NOLOCK) where Cmp_ID In (Select Cmp_ID From T0010_COMPANY_MASTER WITH (NOLOCK) Where is_GroupOFCmp = 1 And Max_Emp_Code = @Max_Emp_Code )  
													and  SUBSTRING(isnull(Code_Date,Convert(varchar(20),00)), PATINDEX('%MM%',isnull(Code_Date_Format,'MM')),2)  = Month(GETDATE())		
													and  Year(System_Date) = Year(GETDATE())
													union all
													Select CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) as Emp_Code from T0060_EMP_MASTER_APP WITH (NOLOCK) where Cmp_ID In (Select Cmp_ID From T0010_COMPANY_MASTER WITH (NOLOCK) Where is_GroupOFCmp = 1 And Max_Emp_Code = @Max_Emp_Code )  
													and  SUBSTRING(isnull(Code_Date,Convert(varchar(20),00)), PATINDEX('%MM%',isnull(Code_Date_Format,'MM')),2)  = Month(GETDATE())		
													and  Year(System_Date) = Year(GETDATE())
													
													)t
												end
													set @len = LEN(CAST (@emp_code as varchar(10)))
													
														if @len > @No_Of_Digits
															set @len = @No_Of_Digits
														
														set @Emp_Code = @Date_Code + REPLICATE ('0',@No_Of_Digits - @len) + @Emp_Code
												
											end
									end
								else
									begin
										If @Branch_Id < 0 
											begin
													select @Emp_Code = max(Emp_Code) from
															(
												Select CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) as Emp_Code from T0080_EMP_MASTER WITH (NOLOCK)
												Where Cmp_ID In (Select Cmp_ID From T0010_COMPANY_MASTER WITH (NOLOCK) Where is_GroupOFCmp =  1 And Max_Emp_Code = @Max_Emp_Code  )
												union all
												Select CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) as Emp_Code from T0060_EMP_MASTER_APP WITH (NOLOCK)
												Where Cmp_ID In (Select Cmp_ID From T0010_COMPANY_MASTER WITH (NOLOCK) Where is_GroupOFCmp =  1 And Max_Emp_Code = @Max_Emp_Code  )
												
												)t
												set @len = LEN(CAST (@emp_code as varchar(10)))
													
													if @len > @No_Of_Digits
														set @len = @No_Of_Digits
														
													set @Emp_Code = @Date_Code + REPLICATE ('0',@No_Of_Digits - @len) + @Emp_Code
											end
										else
											begin
													select @Emp_Code = max(Emp_Code) from
											(
												Select CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) as Emp_Code from T0080_EMP_MASTER WITH (NOLOCK) where Cmp_ID In (Select Cmp_ID From T0010_COMPANY_MASTER WITH (NOLOCK) Where is_GroupOFCmp = 1 And Max_Emp_Code = @Max_Emp_Code )		
												union all
												Select CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) as Emp_Code from T0060_EMP_MASTER_APP WITH (NOLOCK) where Cmp_ID In (Select Cmp_ID From T0010_COMPANY_MASTER WITH (NOLOCK) Where is_GroupOFCmp = 1 And Max_Emp_Code = @Max_Emp_Code )		
											)t
												set @len = LEN(CAST (@emp_code as varchar(10)))
													
													if @len > @No_Of_Digits
														set @len = @No_Of_Digits
														
													set @Emp_Code = @Date_Code + REPLICATE ('0',@No_Of_Digits - @len) + @Emp_Code
											end
									end
							end
					    else if (@Is_Alpha_Numeric_Branchwise = 0  and @Is_Alpha_Numeric_Companywise = 1 ) or ( @Is_Alpha_Numeric_Branchwise = 0 and @Is_Alpha_Numeric_Companywise = 0)
							begin
								if @is_ResetSequance = 1 
									begin
									if @is_JoiningDate_Wise = 1
										begin
											if isdate(@joiningDate) = 1 
												begin
														select @Emp_Code = max(Emp_Code) from
												(
													Select CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) as Emp_Code from T0080_EMP_MASTER WITH (NOLOCK)
													Where Cmp_ID In (Select Cmp_ID From T0010_COMPANY_MASTER WITH (NOLOCK) Where is_GroupOFCmp = 1 And Max_Emp_Code = @Max_Emp_Code )
													and SUBSTRING(isnull(Code_Date,Convert(varchar(20),00)), PATINDEX('%MM%',isnull(Code_Date_Format,'MM')),2)  = Month(@joiningDate)
													and  Year(System_Date) = Year(@joiningDate)
													union all
													Select CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) as Emp_Code from T0060_EMP_MASTER_APP WITH (NOLOCK)
													Where Cmp_ID In (Select Cmp_ID From T0010_COMPANY_MASTER WITH (NOLOCK) Where is_GroupOFCmp = 1 And Max_Emp_Code = @Max_Emp_Code )
													and SUBSTRING(isnull(Code_Date,Convert(varchar(20),00)), PATINDEX('%MM%',isnull(Code_Date_Format,'MM')),2)  = Month(@joiningDate)
													and  Year(System_Date) = Year(@joiningDate)
													
													) t
												end
											else
												begin
													select @Emp_Code = max(Emp_Code) from
												(
													Select CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) as Emp_Code from T0080_EMP_MASTER WITH (NOLOCK)
													Where Cmp_ID In (Select Cmp_ID From T0010_COMPANY_MASTER WITH (NOLOCK) Where is_GroupOFCmp = 1 And Max_Emp_Code = @Max_Emp_Code )
													union all
													Select CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) as Emp_Code from T0060_EMP_MASTER_APP WITH (NOLOCK)
													Where Cmp_ID In (Select Cmp_ID From T0010_COMPANY_MASTER WITH (NOLOCK) Where is_GroupOFCmp = 1 And Max_Emp_Code = @Max_Emp_Code )
												) t
												end
										end
									else
										begin
												select @Emp_Code = max(Emp_Code) from
										(
											Select CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) as Emp_Code from T0080_EMP_MASTER WITH (NOLOCK)
											Where Cmp_ID In (Select Cmp_ID From T0010_COMPANY_MASTER WITH (NOLOCK) Where is_GroupOFCmp = 1 And Max_Emp_Code = @Max_Emp_Code )
											and SUBSTRING(isnull(Code_Date,Convert(varchar(20),00)), PATINDEX('%MM%',isnull(Code_Date_Format,'MM')),2)  = Month(GETDATE())
											and  Year(System_Date) = Year(GETDATE())
											union all
											Select CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) as Emp_Code from T0060_EMP_MASTER_APP  WITH (NOLOCK) 
											Where Cmp_ID In (Select Cmp_ID From T0010_COMPANY_MASTER WITH (NOLOCK) Where is_GroupOFCmp = 1 And Max_Emp_Code = @Max_Emp_Code )
											and SUBSTRING(isnull(Code_Date,Convert(varchar(20),00)), PATINDEX('%MM%',isnull(Code_Date_Format,'MM')),2)  = Month(GETDATE())
											and  Year(System_Date) = Year(GETDATE())
										) t
										end
												set @len = LEN(CAST (@emp_code as varchar(10)))
													
													if @len > @No_Of_Digits
														set @len = @No_Of_Digits
														
													set @Emp_Code = @Date_Code + REPLICATE ('0',@No_Of_Digits - @len) + @Emp_Code
									end
								else
									begin
											select @Emp_Code = max(Emp_Code) from
										(
										Select CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) as Emp_Code from T0080_EMP_MASTER WITH (NOLOCK)
										Where Cmp_ID In (Select Cmp_ID From T0010_COMPANY_MASTER WITH (NOLOCK) Where is_GroupOFCmp = 1 And Max_Emp_Code = @Max_Emp_Code )
										union all
										Select CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) as Emp_Code from T0060_EMP_MASTER_APP WITH (NOLOCK)
										Where Cmp_ID In (Select Cmp_ID From T0010_COMPANY_MASTER WITH (NOLOCK) Where is_GroupOFCmp = 1 And Max_Emp_Code = @Max_Emp_Code )
										
										)t
										set @len = LEN(CAST (@emp_code as varchar(10)))
													
													if @len > @No_Of_Digits
														set @len = @No_Of_Digits
														
													set @Emp_Code = @Date_Code + REPLICATE ('0',@No_Of_Digits - @len) + @Emp_Code
									end	
							end
				End	
		end
	else
		begin
			IF @Max_Emp_Code = 'Company_Wise'
				Begin
				
					If @Is_Alpha_Numeric_Branchwise = 1  and @Is_Alpha_Numeric_Companywise = 1
						begin
							if @Branch_Id > 0 
								begin
										select @Emp_Code = max(Emp_Code) from
							    (
									Select ISNULL(MAX(emp_code),0)+1 as Emp_Code from T0080_EMP_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_Id and Branch_ID=@Branch_Id
									union all
									Select ISNULL(MAX(emp_code),0)+1 as Emp_Code from T0060_EMP_MASTER_APP WITH (NOLOCK) where Cmp_ID=@Cmp_Id and Branch_ID=@Branch_Id
								)t
								set @len = LEN(CAST (@emp_code as varchar(10)))		
											if @len > @No_Of_Digits
											set @len = @No_Of_Digits						
									set @Emp_Code = REPLICATE ('0',@No_Of_Digits - @len) + @Emp_Code
								end
							else
								begin
									select @Emp_Code = max(Emp_Code) from
							    (
									Select ISNULL(MAX(emp_code),0)+1  as Emp_Code from T0080_EMP_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_Id 
									union all
									Select ISNULL(MAX(emp_code),0)+1  as Emp_Code from T0060_EMP_MASTER_APP WITH (NOLOCK) where Cmp_ID=@Cmp_Id
								)t
									set @len = LEN(CAST (@emp_code as varchar(10)))		
									if @len > @No_Of_Digits
											set @len = @No_Of_Digits							
									set @Emp_Code = REPLICATE ('0',@No_Of_Digits - @len) + @Emp_Code
								end
						end
					else if @Is_Alpha_Numeric_Branchwise = 1  and @Is_Alpha_Numeric_Companywise = 0
						begin
							if @Branch_Id > 0 
								begin
									select @Emp_Code = max(Emp_Code) from
							    (
									Select ISNULL(MAX(emp_code),0)+1 as Emp_Code from  T0080_EMP_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_Id and Branch_ID=@Branch_Id	
									union all
									Select ISNULL(MAX(emp_code),0)+1 as Emp_Code  from T0060_EMP_MASTER_APP WITH (NOLOCK) where Cmp_ID=@Cmp_Id and Branch_ID=@Branch_Id	
								)t
									set @len = LEN(CAST (@emp_code as varchar(10)))		
									if @len > @No_Of_Digits
											set @len = @No_Of_Digits
																
									set @Emp_Code = REPLICATE ('0',@No_Of_Digits - @len) + @Emp_Code
								end
							else
								begin
									select @Emp_Code = max(Emp_Code) from
							    (
									Select ISNULL(MAX(emp_code),0)+1 as Emp_Code  from T0080_EMP_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_Id	
									union all
									Select ISNULL(MAX(emp_code),0)+1 as Emp_Code  from T0060_EMP_MASTER_APP WITH (NOLOCK) where Cmp_ID=@Cmp_Id	
								)t
									set @len = LEN(CAST (@emp_code as varchar(10)))		
									if @len > @No_Of_Digits
											set @len = @No_Of_Digits
																
									set @Emp_Code = REPLICATE ('0',@No_Of_Digits - @len) + @Emp_Code
								end
						end
					else if (@Is_Alpha_Numeric_Branchwise = 0  and @Is_Alpha_Numeric_Companywise = 1) or (@Is_Alpha_Numeric_Branchwise = 0 and @Is_Alpha_Numeric_Companywise = 0)
						begin
							--- Uncomment Below code for Competent Client added by Hardik 31/10/2018, DO NOT REMOVE BELOW CODE, IT'S SPECIFIC CODE FOR COMPETENT SYN. CLIENT
							
							--If @Grd_ID = 1 -- Hardik 03/10/2018 for Competent Client, Fix Grade S1 for Training Employees
							--	BEGIN
							--		Select @Emp_Code = ISNULL(MAX(emp_code),0)+1 from T0080_EMP_MASTER where Cmp_ID=@Cmp_Id And Grd_ID=@Grd_Id
							--	END
							--ELSE
							--	BEGIN	
							--		Select @Emp_Code = ISNULL(MAX(emp_code),0)+1 from T0080_EMP_MASTER where Cmp_ID=@Cmp_Id And Grd_ID <> 1
							--	END   
							
								select @Emp_Code = max(Emp_Code) from
							(
							Select  ISNULL(MAX(emp_code),0)+1 as Emp_Code from T0080_EMP_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_Id	
							union all
							Select  ISNULL(MAX(emp_code),0)+1 as Emp_Code from T0060_EMP_MASTER_APP WITH (NOLOCK) where Cmp_ID=@Cmp_Id	
							)t
							
							

							set @len = LEN(CAST (@emp_code as varchar(10)))		
							if @len > @No_Of_Digits
											set @len = @No_Of_Digits
									
									set @Emp_Code = REPLICATE ('0',@No_Of_Digits - @len) + @Emp_Code
						end
				End
			Else If @Max_Emp_Code = 'Group_Company_Wise'
				Begin
					
					If @Is_Alpha_Numeric_Branchwise = 1  and @Is_Alpha_Numeric_Companywise = 1
						begin
							if @Branch_Id > 0 
								begin
									select @Emp_Code = max(Emp_Code) from
								(
									Select ISNULL(MAX(emp_code),0)+1 as Emp_Code from T0080_EMP_MASTER WITH (NOLOCK)
									where Cmp_ID In (Select Cmp_ID From T0010_COMPANY_MASTER WITH (NOLOCK) Where is_GroupOFCmp = 1 And Max_Emp_Code = @Max_Emp_Code ) and Branch_ID=@Branch_Id
									union all
									Select ISNULL(MAX(emp_code),0)+1 as Emp_Code from T0060_EMP_MASTER_APP WITH (NOLOCK)
									where Cmp_ID In (Select Cmp_ID From T0010_COMPANY_MASTER WITH (NOLOCK) Where is_GroupOFCmp = 1 And Max_Emp_Code = @Max_Emp_Code ) and Branch_ID=@Branch_Id
								)t
									set @len = LEN(CAST (@emp_code as varchar(10)))		
											if @len > @No_Of_Digits
											set @len = @No_Of_Digits						
									set @Emp_Code = REPLICATE ('0',@No_Of_Digits - @len) + @Emp_Code
								end
							else
								begin
									--Select @Emp_Code =ISNULL(MAX(emp_code),0)+1 from T0080_EMP_MASTER where Cmp_ID=@Cmp_Id 
									select @Emp_Code = max(Emp_Code) from
									(
									Select ISNULL(MAX(emp_code),0)+1 as Emp_Code from T0080_EMP_MASTER WITH (NOLOCK)
									where Cmp_ID In (Select Cmp_ID From T0010_COMPANY_MASTER WITH (NOLOCK) Where is_GroupOFCmp = 1 And Max_Emp_Code = @Max_Emp_Code ) and Branch_ID=@Branch_Id
									union all
									Select ISNULL(MAX(emp_code),0)+1 as Emp_Code from T0060_EMP_MASTER_APP WITH (NOLOCK)
									where Cmp_ID In (Select Cmp_ID From T0010_COMPANY_MASTER WITH (NOLOCK) Where is_GroupOFCmp = 1 And Max_Emp_Code = @Max_Emp_Code ) and Branch_ID=@Branch_Id
									)t
									set @len = LEN(CAST (@emp_code as varchar(10)))		
									if @len > @No_Of_Digits
											set @len = @No_Of_Digits							
									set @Emp_Code = REPLICATE ('0',@No_Of_Digits - @len) + @Emp_Code
								end
						end
					else if @Is_Alpha_Numeric_Branchwise = 1  and @Is_Alpha_Numeric_Companywise = 0
						begin
							if @Branch_Id > 0 
								begin
									
									select @Emp_Code = max(Emp_Code) from
									(
									Select ISNULL(MAX(emp_code),0)+1 as Emp_Code from T0080_EMP_MASTER WITH (NOLOCK)
									where Cmp_ID In (Select Cmp_ID From T0010_COMPANY_MASTER WITH (NOLOCK) Where is_GroupOFCmp = 1 And Max_Emp_Code = @Max_Emp_Code  ) and Branch_ID=@Branch_Id	
									union all
									Select ISNULL(MAX(emp_code),0)+1 as Emp_Code from T0060_EMP_MASTER_APP WITH (NOLOCK)
									where Cmp_ID In (Select Cmp_ID From T0010_COMPANY_MASTER WITH (NOLOCK) Where is_GroupOFCmp = 1 And Max_Emp_Code = @Max_Emp_Code  ) and Branch_ID=@Branch_Id	
									)t

									set @len = LEN(CAST (@emp_code as varchar(10)))		
									if @len > @No_Of_Digits
											set @len = @No_Of_Digits
																
									set @Emp_Code = REPLICATE ('0',@No_Of_Digits - @len) + @Emp_Code
								end
							else
								begin
								select @Emp_Code = max(Emp_Code) from
									(
									Select ISNULL(MAX(emp_code),0)+1 as Emp_Code from T0080_EMP_MASTER WITH (NOLOCK) where Cmp_ID In (Select Cmp_ID From T0010_COMPANY_MASTER WITH (NOLOCK) Where is_GroupOFCmp = 1 And Max_Emp_Code = @Max_Emp_Code )	
									union all
									Select ISNULL(MAX(emp_code),0)+1 as Emp_Code from T0060_EMP_MASTER_APP WITH (NOLOCK) where Cmp_ID In (Select Cmp_ID From T0010_COMPANY_MASTER WITH (NOLOCK) Where is_GroupOFCmp = 1 And Max_Emp_Code = @Max_Emp_Code )	
									)t
									set @len = LEN(CAST (@emp_code as varchar(10)))		
									if @len > @No_Of_Digits
											set @len = @No_Of_Digits
																
									set @Emp_Code = REPLICATE ('0',@No_Of_Digits - @len) + @Emp_Code
								end
						end
					else if (@Is_Alpha_Numeric_Branchwise = 0  and @Is_Alpha_Numeric_Companywise = 1) or (@Is_Alpha_Numeric_Branchwise = 0 and @Is_Alpha_Numeric_Companywise = 0)
						begin
							-- comment and added by rohit for bma generate date wise code.
							--Select @Emp_Code = ISNULL(MAX(emp_code),0)+1 from T0080_EMP_MASTER where Cmp_ID In (Select Cmp_ID From T0010_COMPANY_MASTER Where is_GroupOFCmp = 1 And Max_Emp_Code = @Max_Emp_Code )		
							
							
							--Select ISNULL(MAX(right(emp_code,@No_Of_Digits)),0) from T0080_EMP_MASTER where Cmp_ID In (Select Cmp_ID From T0010_COMPANY_MASTER Where is_GroupOFCmp = 1 And Max_Emp_Code = @Max_Emp_Code )		
							
							--Modified by Nimesh On 06-July-2016 (If the total length of Emp_Code is exceded from @No_Of_Digits then it was retrieving invalid value)
							if @No_Of_Digits <> 0
									begin
								select @Emp_Code = max(Emp_Code) from
									(
										Select ISNULL(MAX(cast(right(emp_code,@No_Of_Digits) as numeric)),0)+1 as Emp_Code from T0080_EMP_MASTER WITH (NOLOCK) where Cmp_ID In (Select Cmp_ID From T0010_COMPANY_MASTER WITH (NOLOCK) Where is_GroupOFCmp = 1 And Max_Emp_Code = @Max_Emp_Code )	
										union all
										Select ISNULL(MAX(cast(right(emp_code,@No_Of_Digits) as numeric)),0)+1 as Emp_Code from T0060_EMP_MASTER_APP WITH (NOLOCK) where Cmp_ID In (Select Cmp_ID From T0010_COMPANY_MASTER WITH (NOLOCK) Where is_GroupOFCmp = 1 And Max_Emp_Code = @Max_Emp_Code )		
										
								   )t	
								end
							Else
								begin
								select @Emp_Code = max(Emp_Code) from
									(
										Select ISNULL(MAX(cast(emp_code as numeric)),0)+1 as Emp_Code from T0080_EMP_MASTER WITH (NOLOCK) where Cmp_ID In (Select Cmp_ID From T0010_COMPANY_MASTER WITH (NOLOCK) Where is_GroupOFCmp = 1 And Max_Emp_Code = @Max_Emp_Code )		
										union all
										Select ISNULL(MAX(cast(emp_code as numeric)),0)+1 as Emp_Code from T0060_EMP_MASTER_APP WITH (NOLOCK) where Cmp_ID In (Select Cmp_ID From T0010_COMPANY_MASTER WITH (NOLOCK) Where is_GroupOFCmp = 1 And Max_Emp_Code = @Max_Emp_Code )		
								 )t
								end
							--Select @Emp_Code = ISNULL(MAX(emp_code),0)+1 from T0080_EMP_MASTER where Cmp_ID In (Select Cmp_ID From T0010_COMPANY_MASTER Where is_GroupOFCmp = 1 And Max_Emp_Code = @Max_Emp_Code )		
							set @len = LEN(CAST (@emp_code as varchar(10)))		
							if @len > @No_Of_Digits
											set @len = @No_Of_Digits
									
									set @Emp_Code = REPLICATE ('0',@No_Of_Digits - @len) + @Emp_Code
						end
				End
				
		end
			
	set @Get_Alpha_Code = UPPER(@Sample_Code)
	set @Get_Emp_Code = CAST(@Emp_Code as varchar(50))
	
	--Select UPPER(@Sample_Code) as Alpha_Code,@Emp_Code as Emp_Code  --It returns Alpha Employee Code So Donot comment this line
	Select isnull(UPPER(@Sample_Code),'') as Alpha_Code,@Emp_Code as Emp_Code  --It returns Alpha Employee Code So Donot comment this line
    
END



------------------Below as Old Code----------------


	
--	--Declare @Cmp_Code varchar(50)
--	--Declare @Is_Auto_Alpha_Numeric_Code	tinyint
--	--Declare @No_Of_Digits numeric(18, 0)
--	--Declare @Is_Alpha_Numeric_Branchwise tinyint
--	--Declare @Branch_Code varchar(50)	
--	--Declare @Emp_Code numeric
--	--Declare @Alpha_Code varchar(50)

-- --   Select @Cmp_Code=isnull(Cmp_Code,''),@Is_Auto_Alpha_Numeric_Code=isnull(Is_Auto_Alpha_Numeric_Code,0)
--	--	,@Is_Alpha_Numeric_Branchwise=isnull(Is_Alpha_Numeric_Branchwise,0),@No_Of_Digits=isnull(No_Of_Digit_Emp_Code,0) 
-- --   from T0010_COMPANY_MASTER where Cmp_Id=@Cmp_Id
    
-- --   Select @Branch_Code=Branch_Code from T0030_BRANCH_MASTER where Cmp_ID=@Cmp_Id and Branch_ID=@Branch_Id
    
-- --   If @Branch_Code is null
--	--	Set @Branch_Code = ''
    
-- --   If @Is_Alpha_Numeric_Branchwise = 1
--	--	Begin
--	--		If @Branch_Id > 0
--	--			Select @Emp_Code=ISNULL(MAX(emp_code),0)+1 from T0080_EMP_MASTER where Cmp_ID=@Cmp_Id and Branch_ID=@Branch_Id
--	--		Else
--	--			Select @Emp_Code=ISNULL(MAX(emp_code),0)+1 from T0080_EMP_MASTER where Cmp_ID=@Cmp_Id	
--	--	End
--	--Else
--	--	Begin
--	--		Select @Emp_Code=ISNULL(MAX(emp_code),0)+1 from T0080_EMP_MASTER where Cmp_ID=@Cmp_Id	
--	--	End
    
		
--	--IF @Is_Auto_Alpha_Numeric_Code = 1
--	--	Begin		
--	--		If @Cmp_Code IS NULL
--	--			Begin
--	--				Set @Alpha_Code = @Branch_Code					
--	--			End
--	--		Else
--	--			Begin
--	--				Set @Alpha_Code = @Cmp_Code + @Branch_Code					
--	--			End	
--	--	END
--	--ELSE
--	--	BEGIN
--	--		Set @Alpha_Code = ''
--	--	END
		
--	--Select @Alpha_Code as Alpha_Code,@Emp_Code as Emp_Code
--	--- New SP For EMP_Code_Setting
--	SET NOCOUNT ON;
	
--	Declare @Cmp_Code varchar(50)
--	Declare @Is_Auto_Alpha_Numeric_Code	tinyint
--	Declare @No_Of_Digits numeric(18, 0)
--	Declare @Is_Alpha_Numeric_Branchwise tinyint
--	Declare @Branch_Code varchar(50)	
--	Declare @Branch_Name varchar(50)
--	Declare @Emp_Code varchar(50) 
--	Declare @Alpha_Code varchar(50)
--	Declare @Is_Alpha_Numeric_Companywise tinyint 
--	Declare @Is_Date_Wise tinyint 
--	Declare @is_JoiningDate_Wise tinyint 
--	Declare @is_ResetSequance tinyint 
--	Declare @Date_Format varchar(20) 
--	Declare @Date_Code varchar(40) 
--	Declare @Is_GroupOFCmp Numeric
--	Declare @Max_Emp_Code  Varchar(50)
	
--	Set @Is_Date_Wise = 0
--	set @Emp_Code = ''
--	set @Is_Alpha_Numeric_Companywise = 0
--	set @Is_Date_Wise = 0
--	set @is_JoiningDate_Wise= 0
--	set @is_ResetSequance = 0
--	set @Date_Format = ''
--	set @Date_Code = ''
--	Set @Is_GroupOFCmp = 0
--	Set @Max_Emp_Code = 'Company_Wise'
	
--    Select @Cmp_Code=isnull(Cmp_Code,''),@Is_Auto_Alpha_Numeric_Code=isnull(Is_Auto_Alpha_Numeric_Code,0)
--		,@Is_Alpha_Numeric_Branchwise=isnull(Is_Alpha_Numeric_Branchwise,0),@No_Of_Digits=isnull(No_Of_Digit_Emp_Code,0),@Is_Alpha_Numeric_Companywise = ISNULL(Is_CompanyWise,0) 
--		,@Is_Date_Wise = ISNULL(Is_DateWise,0),@is_JoiningDate_Wise = ISNULL(Is_JoiningDateWise,0),@Date_Format = ISNULL(DateFormat,'YYYYMMDD'),@is_ResetSequance = ISNULL(Reset_Sequance,0)
--		,@Is_GroupOFCmp = ISNULL(Is_GroupOFCmp,0) ,@Max_Emp_Code = Max_Emp_Code	--Ankit 12072014
--    From T0010_COMPANY_MASTER where Cmp_Id=@Cmp_Id
    
--    Select @Branch_Code=Branch_Code, @Branch_Name = Branch_Name from T0030_BRANCH_MASTER where Cmp_ID=@Cmp_Id and Branch_ID=@Branch_Id
--    If @Branch_Code is null
--		Set @Branch_Code = ''
--	If @Branch_Name is null
--		Set @Branch_Name = ''
		
--	declare @DayJoiningDate as varchar(2) 
--	declare @MonthJoingDate as varchar(2)
--	declare @DayCurrentDate as varchar(2) 
--	declare @MonthCurrentDate as varchar(2) 
--	set @DayJoiningDate  = ''
--	set @MonthJoingDate = ''
--	set @DayCurrentDate  = ''
--	set @MonthCurrentDate  = ''
	
--	if @is_JoiningDate_Wise = 1 and  @joiningDate <> ''
--		begin
	
--			if DAY(@joiningDate) < 10
--					set @DayJoiningDate = '0' + CONVERT(varchar(2), DAY(@joiningDate))
--				else
--					set @DayJoiningDate = CONVERT(varchar(2), DAY(@joiningDate))
					
--			if Month(@joiningDate) < 10
--					set @MonthJoingDate = '0' + CONVERT(varchar(2),Month(@joiningDate))
--				else
--					set  @MonthJoingDate = CONVERT(varchar(2), Month(@joiningDate))		
--		end
--	else
--		begin
--			if DAY(GETDATE()) < 10
--					set @DayCurrentDate = '0' + CONVERT(varchar(2), DAY(GETDATE()))
--				else
--					set @DayCurrentDate = Convert(varchar(2),DAY(GETDATE()))
					
--			if Month(GETDATE()) < 10
--					set @MonthCurrentDate = '0' + CONVERT(varchar(2),Month(GETDATE()))
--				else
--					set @MonthCurrentDate = Convert(varchar(2),Month(GETDATE()))
--		end
	
--	if  @Date_Format = 'DDMM'	
--	begin
	
--		if @is_JoiningDate_Wise = 1 and  @joiningDate <> ''
--			begin		
--				set @Date_Code =  @DayJoiningDate + @MonthJoingDate
--			end
--		else if @is_JoiningDate_Wise = 0	 
--			set @Date_Code =  @DayCurrentDate + @MonthCurrentDate
--	end
--	if  @Date_Format = 'DDMMYY'	
--	begin
--		if @is_JoiningDate_Wise = 1 and  @joiningDate <> ''
--			set @Date_Code =   @DayJoiningDate + @MonthJoingDate +  substring(Convert(varchar(4),Year(@joiningDate)),3,2)
--		else if @is_JoiningDate_Wise = 0	 
--			set @Date_Code =  @DayCurrentDate + @MonthCurrentDate + substring(Convert(varchar(4),Year(GETDATE())),3,2)
--	end
--	else if @Date_Format = 'DDMMYYYY'
--	begin
	
--	if @is_JoiningDate_Wise = 1 and  @joiningDate <> ''
--			set @Date_Code =  @DayJoiningDate + @MonthJoingDate + CONVERT(varchar(4),Year(@joiningDate))
--		else if @is_JoiningDate_Wise = 0	 
--			set @Date_Code =  @DayCurrentDate + @MonthCurrentDate + CONVERT(varchar(4),Year(GETDATE()))
--	end
	
--	else if  @Date_Format = 'MMDD'	
--	begin
	
--		if @is_JoiningDate_Wise = 1 and  @joiningDate <> ''
--			set @Date_Code =  @MonthJoingDate + @DayJoiningDate
--		else if @is_JoiningDate_Wise = 0	 
--			set @Date_Code =  @MonthCurrentDate  + @DayCurrentDate
--	end
--	else if @Date_Format = 'MMYY'
--	begin
--		if @is_JoiningDate_Wise = 1 and  @joiningDate <> ''
--			set @Date_Code =  @MonthJoingDate +  substring(Convert(varchar(4),Year(@joiningDate)),3,2)
--		else if @is_JoiningDate_Wise = 0	 
--			set @Date_Code =  @MonthCurrentDate + substring(Convert(varchar(4),Year(GETDATE())),3,2)
--	end	
--	else if @Date_Format = 'MMYYYY'
--	begin
	
--		if @is_JoiningDate_Wise = 1 and  @joiningDate <> ''
--			set @Date_Code =  @MonthJoingDate + CONVERT(varchar(4),Year(@joiningDate))
--		else if @is_JoiningDate_Wise = 0	 
--			set @Date_Code =  @MonthCurrentDate + convert(varchar(4),Year(GETDATE()))
--	end
--	else if @Date_Format = 'MMDDYY'
--	begin
	
--		if @is_JoiningDate_Wise = 1 and  @joiningDate <> ''
--			set @Date_Code =  @MonthJoingDate + @DayJoiningDate + substring(Convert(varchar(4),Year(@joiningDate)),3,2)
--		else if @is_JoiningDate_Wise = 0	 
--			set @Date_Code =  @MonthCurrentDate + @DayCurrentDate + substring(Convert(varchar(4),Year(GETDATE())),3,2)
--	end
--	else if @Date_Format = 'MMDDYYYY'
--	begin
	
--		if @is_JoiningDate_Wise = 1 and  @joiningDate <> ''
--			set @Date_Code =  @MonthJoingDate + @DayJoiningDate+ Convert(varchar(4),Year(@joiningDate))
--		else if @is_JoiningDate_Wise = 0	 
--			set @Date_Code =  @MonthCurrentDate + @DayCurrentDate + Convert(varchar(4),Year(GETDATE()))
--	end
--	else if @Date_Format = 'MMYYDD'
--	begin
	
--		if @is_JoiningDate_Wise = 1 and  @joiningDate <> ''
--			set @Date_Code =  @MonthJoingDate + substring(Convert(varchar(4),Year(@joiningDate)),3,2) + @DayJoiningDate
--		else if @is_JoiningDate_Wise = 0	 
--			set @Date_Code =  @MonthCurrentDate + substring(Convert(varchar(4),Year(GETDATE())),3,2) + @DayCurrentDate
--	end
--	else if @Date_Format = 'MMYYYYDD'
--	begin
	
--		if @is_JoiningDate_Wise = 1 and  @joiningDate <> ''
--			set @Date_Code =  @MonthJoingDate + Convert(varchar(4),Year(@joiningDate)) + @DayJoiningDate
--		else if @is_JoiningDate_Wise = 0	 
--			set @Date_Code =  @MonthCurrentDate + Convert(varchar(4),Year(GETDATE())) + @DayCurrentDate
--	end
--	else if @Date_Format = 'YYMM'
--	begin
	
--		if @is_JoiningDate_Wise = 1 and  @joiningDate <> ''
--			set @Date_Code =  substring(Convert(varchar(4),Year(@joiningDate)),3,2) + @MonthJoingDate
--		else if @is_JoiningDate_Wise = 0	 
--			set @Date_Code =  substring(Convert(varchar(4),Year(GETDATE())),3,2) + @MonthCurrentDate
--	end
--	else if @Date_Format = 'YYDDMM'
--	begin
	
--		if @is_JoiningDate_Wise = 1 and  @joiningDate <> ''
--			set @Date_Code =  substring(Convert(varchar(4),Year(@joiningDate)),3,2) + @DayJoiningDate + @MonthJoingDate
--		else if @is_JoiningDate_Wise = 0	 
--			set @Date_Code =  substring(Convert(varchar(4),Year(GETDATE())),3,2) + @DayCurrentDate + @MonthCurrentDate
--	end
--	else if @Date_Format = 'YYMMDD'
--	begin
	
--		if @is_JoiningDate_Wise = 1 and  @joiningDate <> ''
--			set @Date_Code =  substring(Convert(varchar(4),Year(@joiningDate)),3,2) + @MonthJoingDate + @DayJoiningDate
--		else if @is_JoiningDate_Wise = 0	 
--			set @Date_Code =  substring(Convert(varchar(4),Year(GETDATE())),3,2) + @MonthCurrentDate + @DayCurrentDate
--	end
--	else if @Date_Format = 'YYYYMM'
--	begin
	
--	if @is_JoiningDate_Wise = 1 and  @joiningDate <> ''
--			set @Date_Code =  CONVERT(varchar(4),Year(@joiningDate)) + @MonthJoingDate
--		else if @is_JoiningDate_Wise = 0	 
--			set @Date_Code =  Convert(varchar(4),Year(GETDATE())) + @MonthCurrentDate
--	end
--	else if @Date_Format = 'YYYYMMDD'
--	begin
--	if @is_JoiningDate_Wise = 1 and  @joiningDate <> ''
--			set @Date_Code =  CONVERT(varchar(4),Year(@joiningDate)) + @MonthJoingDate + @DayJoiningDate
--		else if @is_JoiningDate_Wise = 0	 
--			set @Date_Code =  CONVERT(varchar(4),Year(GETDATE()))  + @MonthCurrentDate+  @DayCurrentDate
--	end
--	else if @Date_Format = 'YYYYDDMM'
--	begin
--	if @is_JoiningDate_Wise = 1 and  @joiningDate <> ''
--			set @Date_Code =  CONVERT(varchar(4),Year(@joiningDate))+ @DayJoiningDate + @MonthJoingDate
--		else if @is_JoiningDate_Wise = 0	 
--			set @Date_Code =  convert(varchar(4),Year(GETDATE())) + @DayCurrentDate + @MonthCurrentDate
--	end
--	Declare @len as numeric
	
--    if len(@Branch_Name) >= 3  and @Branch_Code = '' 
--		set @Branch_Code = substring(@Branch_Name,1,3)	
		
--	if LEN(@Branch_Code) > 3
--		set @Branch_Code = SUBSTRING(@Branch_Code,1,3)		
	
	
--	if @Is_Date_Wise = 1  and @Is_Only_Emp_Code = 0
--		begin
		
--			IF @Max_Emp_Code = 'Company_Wise'
--				Begin
					
--					set @Emp_Code = @Date_Code	
--						If @Is_Alpha_Numeric_Branchwise = 1  and @Is_Alpha_Numeric_Companywise = 1
--							begin
--								if @is_ResetSequance = 1 
--									begin
--										if @Branch_Id > 0 
--											begin
--													if @is_JoiningDate_Wise = 1
--														begin
--															if isdate(@joiningDate) = 1 
--																begin
--																	Select @Emp_Code = CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) from T0080_EMP_MASTER where Cmp_ID=@Cmp_Id and Branch_ID=@Branch_Id  
--																	and  SUBSTRING(isnull(Code_Date,Convert(varchar(20),00)), PATINDEX('%MM%',isnull(Code_Date_Format,'MM')),2)  = Month(@joiningDate)
--																	and  Year(System_Date) = Year(@joiningDate)	
--																end
--															else
--																begin
--																	Select @Emp_Code = CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) from T0080_EMP_MASTER where Cmp_ID=@Cmp_Id and Branch_ID=@Branch_Id  
--																end
--														end
--													else
--														begin
--															Select @Emp_Code = CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) from T0080_EMP_MASTER where Cmp_ID=@Cmp_Id and Branch_ID=@Branch_Id  
--															and  SUBSTRING(isnull(Code_Date,Convert(varchar(20),00)), PATINDEX('%MM%',isnull(Code_Date_Format,'MM')),2)  = Month(GETDATE())
--															and  Year(System_Date) = Year(GETDATE())	
--														end
														
--													set @len = LEN(CAST (@emp_code as varchar(10)))
													
--													if @len > @No_Of_Digits
--														set @len = @No_Of_Digits
														
--													set @Emp_Code = @Date_Code + REPLICATE ('0',@No_Of_Digits - @len) + @Emp_Code
													
													
--											end
--										else
--											begin
--												if @is_JoiningDate_Wise = 1
--													begin
													
--														if isdate(@joiningDate) = 1 
--																begin
--																	Select @Emp_Code = CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) from T0080_EMP_MASTER where Cmp_ID=@Cmp_Id  
--																	and  SUBSTRING(isnull(Code_Date,Convert(varchar(20),00)), PATINDEX('%MM%',isnull(Code_Date_Format,'MM')),2)  = Month(@joiningDate)
--																	and  Year(System_Date) = Year(@joiningDate)	
--																end
--															else
--																begin
--																	Select @Emp_Code = CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) from T0080_EMP_MASTER where Cmp_ID=@Cmp_Id   
--																end
--													end
--												else
--													begin
													
--														Select @Emp_Code = CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) from T0080_EMP_MASTER where Cmp_ID=@Cmp_Id 
--														and  SUBSTRING(isnull(Code_Date,Convert(varchar(20),00)), PATINDEX('%MM%',isnull(Code_Date_Format,'MM')),2)  = Month(GETDATE())		
--														and  Year(System_Date) = Year(GETDATE())
--													end	
--													set @len = LEN(CAST (@emp_code as varchar(10)))
													
--													if @len > @No_Of_Digits
--														set @len = @No_Of_Digits
														
--													set @Emp_Code = @Date_Code + REPLICATE ('0',@No_Of_Digits - @len) + @Emp_Code
			
--											end 
--									end
--								else
--									begin
--										if @Branch_Id > 0 
--											begin
--												Select @Emp_Code = CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) from T0080_EMP_MASTER where Cmp_ID=@Cmp_Id and Branch_ID=@Branch_Id  
												
--												set @len = LEN(CAST (@emp_code as varchar(10)))
													
--													if @len > @No_Of_Digits
--														set @len = @No_Of_Digits
														
--													set @Emp_Code = @Date_Code + REPLICATE ('0',@No_Of_Digits - @len) + @Emp_Code
--											end	
--										else
--											begin
--												Select @Emp_Code = CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) from T0080_EMP_MASTER where Cmp_ID=@Cmp_Id 
--												set @len = LEN(CAST (@emp_code as varchar(10)))
													
--													if @len > @No_Of_Digits
--														set @len = @No_Of_Digits
													
--													set @Emp_Code = @Date_Code + REPLICATE ('0',@No_Of_Digits - @len) + @Emp_Code
										
--											end
--										end
--							end
--						else if @Is_Alpha_Numeric_Branchwise = 1  and @Is_Alpha_Numeric_Companywise = 0
--							begin
--								if @is_ResetSequance = 1 
--									begin
--										if @Branch_Id > 0
--											begin 
--												if @is_JoiningDate_Wise = 1
--													begin
--													if isdate(@joiningDate) = 1  
--														begin
--															Select @Emp_Code = CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) from T0080_EMP_MASTER where Cmp_ID=@Cmp_Id and Branch_ID=@Branch_Id 
--															and  SUBSTRING(isnull(Code_Date,Convert(varchar(20),00)), PATINDEX('%MM%',isnull(Code_Date_Format,'MM')),2)  = Month(@joiningDate)		
--															and  Year(System_Date) = Year(@joiningDate)
--														end
--													else
--														begin
--															Select @Emp_Code = CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) from T0080_EMP_MASTER where Cmp_ID=@Cmp_Id and Branch_ID=@Branch_Id 
--														end
--													end
--												else
--													begin
--														Select @Emp_Code = CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) from T0080_EMP_MASTER where Cmp_ID=@Cmp_Id and Branch_ID=@Branch_Id 
--														and  SUBSTRING(isnull(Code_Date,Convert(varchar(20),00)), PATINDEX('%MM%',isnull(Code_Date_Format,'MM')),2)  = Month(GETDATE())		
--														and  Year(System_Date) = Year(GETDATE())		
--													end
--														set @len = LEN(CAST (@emp_code as varchar(10)))
													
--														if @len > @No_Of_Digits
--															set @len = @No_Of_Digits
														
--														set @Emp_Code = @Date_Code + REPLICATE ('0',@No_Of_Digits - @len) + @Emp_Code
													
--											end
--										else	
--											begin
--											if @is_JoiningDate_Wise = 1
--												begin
--													if isdate(@joiningDate) = 1  
--														begin
--															Select @Emp_Code = CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) from T0080_EMP_MASTER where Cmp_ID=@Cmp_Id  
--															and  SUBSTRING(isnull(Code_Date,Convert(varchar(20),00)), PATINDEX('%MM%',isnull(Code_Date_Format,'MM')),2)  = 	Month(@joiningDate)		
--															and  Year(System_Date) = Year(@joiningDate)
--														end
--													else
--														Begin
--															Select @Emp_Code = CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) from T0080_EMP_MASTER where Cmp_ID=@Cmp_Id  
--														end	
														
--												end
--											else
--												begin
--													Select @Emp_Code = CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) from T0080_EMP_MASTER where Cmp_ID=@Cmp_Id  
--													and  SUBSTRING(isnull(Code_Date,Convert(varchar(20),00)), PATINDEX('%MM%',isnull(Code_Date_Format,'MM')),2)  = Month(GETDATE())		
--													and  Year(System_Date) = Year(GETDATE())
--												end
--													set @len = LEN(CAST (@emp_code as varchar(10)))
													
--														if @len > @No_Of_Digits
--															set @len = @No_Of_Digits
														
--														set @Emp_Code = @Date_Code + REPLICATE ('0',@No_Of_Digits - @len) + @Emp_Code
												
--											end
--									end
--								else
--									begin
--										if @Branch_Id > 0 
--											begin
--												Select @Emp_Code = CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) from T0080_EMP_MASTER where Cmp_ID=@Cmp_Id and Branch_ID=@Branch_Id		
												
--												set @len = LEN(CAST (@emp_code as varchar(10)))
													
--													if @len > @No_Of_Digits
--														set @len = @No_Of_Digits
														
--													set @Emp_Code = @Date_Code + REPLICATE ('0',@No_Of_Digits - @len) + @Emp_Code
--											end	
--										else
--											begin
--												Select @Emp_Code =  CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) from T0080_EMP_MASTER where Cmp_ID=@Cmp_Id 		
--												set @len = LEN(CAST (@emp_code as varchar(10)))
													
--													if @len > @No_Of_Digits
--														set @len = @No_Of_Digits
														
--													set @Emp_Code = @Date_Code + REPLICATE ('0',@No_Of_Digits - @len) + @Emp_Code
--											end
--									end
--							end
--					    else if (@Is_Alpha_Numeric_Branchwise = 0  and @Is_Alpha_Numeric_Companywise = 1 ) or ( @Is_Alpha_Numeric_Branchwise = 0 and @Is_Alpha_Numeric_Companywise = 0)
--							begin
--								if @is_ResetSequance = 1 
--									begin
--									if @is_JoiningDate_Wise = 1
--										begin
--											if isdate(@joiningDate) = 1 
--												begin
--													Select @Emp_Code = CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1)from T0080_EMP_MASTER where Cmp_ID=@Cmp_Id	
--													and SUBSTRING(isnull(Code_Date,Convert(varchar(20),00)), PATINDEX('%MM%',isnull(Code_Date_Format,'MM')),2)  = Month(@joiningDate)
--													and  Year(System_Date) = Year(@joiningDate)
--												end
--											else
--												begin
--													Select @Emp_Code = CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1)from T0080_EMP_MASTER where Cmp_ID=@Cmp_Id	
--												end
--										end
--									else
--										begin
--											Select @Emp_Code = CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1)from T0080_EMP_MASTER where Cmp_ID=@Cmp_Id	
--											and SUBSTRING(isnull(Code_Date,Convert(varchar(20),00)), PATINDEX('%MM%',isnull(Code_Date_Format,'MM')),2)  = Month(GETDATE())
--											and  Year(System_Date) = Year(GETDATE())
--										end
--												set @len = LEN(CAST (@emp_code as varchar(10)))
													
--													if @len > @No_Of_Digits
--														set @len = @No_Of_Digits
														
--													set @Emp_Code = @Date_Code + REPLICATE ('0',@No_Of_Digits - @len) + @Emp_Code
--									end
--								else
--									begin
--										Select @Emp_Code = CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) from T0080_EMP_MASTER where Cmp_ID=@Cmp_Id	
--										set @len = LEN(CAST (@emp_code as varchar(10)))
													
--													if @len > @No_Of_Digits
--														set @len = @No_Of_Digits
														
--													set @Emp_Code = @Date_Code + REPLICATE ('0',@No_Of_Digits - @len) + @Emp_Code
--									end	
--							end
--				End
--			Else If @Max_Emp_Code = 'Group_Company_Wise'
--				Begin
				
--					set @Emp_Code = @Date_Code	
--						If @Is_Alpha_Numeric_Branchwise = 1  and @Is_Alpha_Numeric_Companywise = 1
--							begin
							
--								if @is_ResetSequance = 1 
--									begin
									
--										if @Branch_Id < 0 
--											begin
--												if @is_JoiningDate_Wise = 1
--													begin
													
--														if isdate(@joiningDate) = 1 
--															begin
--																Select @Emp_Code = CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) from T0080_EMP_MASTER
--																Where Cmp_ID In (Select Cmp_ID From T0010_COMPANY_MASTER Where is_GroupOFCmp = 1)
											
--																and  SUBSTRING(isnull(Code_Date,Convert(varchar(20),00)), PATINDEX('%MM%',isnull(Code_Date_Format,'MM')),2)  = Month(@joiningDate)
--																and  Year(System_Date) = Year(@joiningDate)	
--															end
--														else
--															begin
--																Select @Emp_Code = CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) from T0080_EMP_MASTER
--																Where Cmp_ID In (Select Cmp_ID From T0010_COMPANY_MASTER Where is_GroupOFCmp = 1)
											
--															end
--													end
--												else
--													begin
													
--														Select @Emp_Code = CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) from T0080_EMP_MASTER 
--														Where Cmp_ID In (Select Cmp_ID From T0010_COMPANY_MASTER Where is_GroupOFCmp = 1)
												
--														and  SUBSTRING(isnull(Code_Date,Convert(varchar(20),00)), PATINDEX('%MM%',isnull(Code_Date_Format,'MM')),2)  = Month(GETDATE())		
--														and  Year(System_Date) = Year(GETDATE())
--													end	
--													set @len = LEN(CAST (@emp_code as varchar(10)))
													
--													if @len > @No_Of_Digits
--														set @len = @No_Of_Digits
														
--													set @Emp_Code = @Date_Code + REPLICATE ('0',@No_Of_Digits - @len) + @Emp_Code
			
--											end 
--										else
--											begin
											
--											if @is_JoiningDate_Wise = 1
--													begin
													
--														if isdate(@joiningDate) = 1 
--																begin
--																	Select @Emp_Code = CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) from T0080_EMP_MASTER where Cmp_ID In (Select Cmp_ID From T0010_COMPANY_MASTER Where is_GroupOFCmp = 1) 
--																	and  SUBSTRING(isnull(Code_Date,Convert(varchar(20),00)), PATINDEX('%MM%',isnull(Code_Date_Format,'MM')),2)  = Month(@joiningDate)
--																	and  Year(System_Date) = Year(@joiningDate)	
--																end
--															else
--																begin
																
--																	Select @Emp_Code = CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) from T0080_EMP_MASTER where Cmp_ID In (Select Cmp_ID From T0010_COMPANY_MASTER Where is_GroupOFCmp = 1)   
--																end
--													end
--												else
--													begin
													
--														Select @Emp_Code = CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) from T0080_EMP_MASTER where Cmp_ID In (Select Cmp_ID From T0010_COMPANY_MASTER Where is_GroupOFCmp = 1) 
--														and  SUBSTRING(isnull(Code_Date,Convert(varchar(20),00)), PATINDEX('%MM%',isnull(Code_Date_Format,'MM')),2)  = Month(GETDATE())		
--														and  Year(System_Date) = Year(GETDATE())
--													end	
--													set @len = LEN(CAST (@emp_code as varchar(10)))
													
--													if @len > @No_Of_Digits
--														set @len = @No_Of_Digits
														
--													set @Emp_Code = @Date_Code + REPLICATE ('0',@No_Of_Digits - @len) + @Emp_Code
--											end
--									  end
--								else
--									begin
--										if @Branch_Id < 0 
--											begin
--												Select @Emp_Code = CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) from T0080_EMP_MASTER 
--												Where Cmp_ID In (Select Cmp_ID From T0010_COMPANY_MASTER Where is_GroupOFCmp = 1)
												
--												set @len = LEN(CAST (@emp_code as varchar(10)))
													
--													if @len > @No_Of_Digits
--														set @len = @No_Of_Digits
													
--													set @Emp_Code = @Date_Code + REPLICATE ('0',@No_Of_Digits - @len) + @Emp_Code
										
--											end
--										else
--											begin
--												Select @Emp_Code = CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) from T0080_EMP_MASTER where Cmp_ID In (Select Cmp_ID From T0010_COMPANY_MASTER Where is_GroupOFCmp = 1)
--												set @len = LEN(CAST (@emp_code as varchar(10)))
													
--													if @len > @No_Of_Digits
--														set @len = @No_Of_Digits
													
--													set @Emp_Code = @Date_Code + REPLICATE ('0',@No_Of_Digits - @len) + @Emp_Code
										
--											end
											
--										end
--							end
--						else if @Is_Alpha_Numeric_Branchwise = 1  and @Is_Alpha_Numeric_Companywise = 0
--							begin
--								if @is_ResetSequance = 1 
--									begin
--										If @Branch_Id < 0
--											begin
--												if @is_JoiningDate_Wise = 1
--													begin
--														if isdate(@joiningDate) = 1  
--															begin
--																Select @Emp_Code = CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) from T0080_EMP_MASTER
--																Where Cmp_ID In (Select Cmp_ID From T0010_COMPANY_MASTER Where is_GroupOFCmp = 1)
--																and  SUBSTRING(isnull(Code_Date,Convert(varchar(20),00)), PATINDEX('%MM%',isnull(Code_Date_Format,'MM')),2)  = 	Month(@joiningDate)		
--																and  Year(System_Date) = Year(@joiningDate)
--															end
--														else
--															Begin
--																Select @Emp_Code = CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) from T0080_EMP_MASTER 
--																Where Cmp_ID In (Select Cmp_ID From T0010_COMPANY_MASTER Where is_GroupOFCmp = 1)
--															end	
															
--													end
--												else
--													begin
--														Select @Emp_Code = CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) from T0080_EMP_MASTER 
--														Where Cmp_ID In (Select Cmp_ID From T0010_COMPANY_MASTER Where is_GroupOFCmp = 1)
--														and  SUBSTRING(isnull(Code_Date,Convert(varchar(20),00)), PATINDEX('%MM%',isnull(Code_Date_Format,'MM')),2)  = Month(GETDATE())		
--														and  Year(System_Date) = Year(GETDATE())
--													end
--														set @len = LEN(CAST (@emp_code as varchar(10)))
														
--															if @len > @No_Of_Digits
--																set @len = @No_Of_Digits
															
--															set @Emp_Code = @Date_Code + REPLICATE ('0',@No_Of_Digits - @len) + @Emp_Code
												
--											end
--										else	
--											begin
--											if @is_JoiningDate_Wise = 1
--												begin
--													if isdate(@joiningDate) = 1  
--														begin
--															Select @Emp_Code = CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) from T0080_EMP_MASTER where Cmp_ID In (Select Cmp_ID From T0010_COMPANY_MASTER Where is_GroupOFCmp = 1) 
--															and  SUBSTRING(isnull(Code_Date,Convert(varchar(20),00)), PATINDEX('%MM%',isnull(Code_Date_Format,'MM')),2)  = 	Month(@joiningDate)		
--															and  Year(System_Date) = Year(@joiningDate)
--														end
--													else
--														Begin
--															Select @Emp_Code = CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) from T0080_EMP_MASTER where Cmp_ID In (Select Cmp_ID From T0010_COMPANY_MASTER Where is_GroupOFCmp = 1) 
--														end	
														
--												end
--											else
--												begin
--													Select @Emp_Code = CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) from T0080_EMP_MASTER where Cmp_ID In (Select Cmp_ID From T0010_COMPANY_MASTER Where is_GroupOFCmp = 1)  
--													and  SUBSTRING(isnull(Code_Date,Convert(varchar(20),00)), PATINDEX('%MM%',isnull(Code_Date_Format,'MM')),2)  = Month(GETDATE())		
--													and  Year(System_Date) = Year(GETDATE())
--												end
--													set @len = LEN(CAST (@emp_code as varchar(10)))
													
--														if @len > @No_Of_Digits
--															set @len = @No_Of_Digits
														
--														set @Emp_Code = @Date_Code + REPLICATE ('0',@No_Of_Digits - @len) + @Emp_Code
												
--											end
--									end
--								else
--									begin
--										If @Branch_Id < 0 
--											begin
--												Select @Emp_Code =  CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) from T0080_EMP_MASTER 
--												Where Cmp_ID In (Select Cmp_ID From T0010_COMPANY_MASTER Where is_GroupOFCmp = 1)
												
--												set @len = LEN(CAST (@emp_code as varchar(10)))
													
--													if @len > @No_Of_Digits
--														set @len = @No_Of_Digits
														
--													set @Emp_Code = @Date_Code + REPLICATE ('0',@No_Of_Digits - @len) + @Emp_Code
--											end
--										else
--											begin
--												Select @Emp_Code =  CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) from T0080_EMP_MASTER where Cmp_ID In (Select Cmp_ID From T0010_COMPANY_MASTER Where is_GroupOFCmp = 1)		
--												set @len = LEN(CAST (@emp_code as varchar(10)))
													
--													if @len > @No_Of_Digits
--														set @len = @No_Of_Digits
														
--													set @Emp_Code = @Date_Code + REPLICATE ('0',@No_Of_Digits - @len) + @Emp_Code
--											end
--									end
--							end
--					    else if (@Is_Alpha_Numeric_Branchwise = 0  and @Is_Alpha_Numeric_Companywise = 1 ) or ( @Is_Alpha_Numeric_Branchwise = 0 and @Is_Alpha_Numeric_Companywise = 0)
--							begin
--								if @is_ResetSequance = 1 
--									begin
--									if @is_JoiningDate_Wise = 1
--										begin
--											if isdate(@joiningDate) = 1 
--												begin
--													Select @Emp_Code = CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1)from T0080_EMP_MASTER 
--													Where Cmp_ID In (Select Cmp_ID From T0010_COMPANY_MASTER Where is_GroupOFCmp = 1)
--													and SUBSTRING(isnull(Code_Date,Convert(varchar(20),00)), PATINDEX('%MM%',isnull(Code_Date_Format,'MM')),2)  = Month(@joiningDate)
--													and  Year(System_Date) = Year(@joiningDate)
--												end
--											else
--												begin
--													Select @Emp_Code = CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1)from T0080_EMP_MASTER 
--													Where Cmp_ID In (Select Cmp_ID From T0010_COMPANY_MASTER Where is_GroupOFCmp = 1)
--												end
--										end
--									else
--										begin
--											Select @Emp_Code = CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1)from T0080_EMP_MASTER 
--											Where Cmp_ID In (Select Cmp_ID From T0010_COMPANY_MASTER Where is_GroupOFCmp = 1)
--											and SUBSTRING(isnull(Code_Date,Convert(varchar(20),00)), PATINDEX('%MM%',isnull(Code_Date_Format,'MM')),2)  = Month(GETDATE())
--											and  Year(System_Date) = Year(GETDATE())
--										end
--												set @len = LEN(CAST (@emp_code as varchar(10)))
													
--													if @len > @No_Of_Digits
--														set @len = @No_Of_Digits
														
--													set @Emp_Code = @Date_Code + REPLICATE ('0',@No_Of_Digits - @len) + @Emp_Code
--									end
--								else
--									begin
--										Select @Emp_Code = CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) from T0080_EMP_MASTER 
--										Where Cmp_ID In (Select Cmp_ID From T0010_COMPANY_MASTER Where is_GroupOFCmp = 1)
--										set @len = LEN(CAST (@emp_code as varchar(10)))
													
--													if @len > @No_Of_Digits
--														set @len = @No_Of_Digits
														
--													set @Emp_Code = @Date_Code + REPLICATE ('0',@No_Of_Digits - @len) + @Emp_Code
--									end	
--							end
--				End	
--		end
--	else
--		begin
--			IF @Max_Emp_Code = 'Company_Wise'
--				Begin
--					If @Is_Alpha_Numeric_Branchwise = 1  and @Is_Alpha_Numeric_Companywise = 1
--						begin
--							if @Branch_Id > 0 
--								begin
--									Select @Emp_Code =ISNULL(MAX(emp_code),0)+1 from T0080_EMP_MASTER where Cmp_ID=@Cmp_Id and Branch_ID=@Branch_Id
--									set @len = LEN(CAST (@emp_code as varchar(10)))		
--											if @len > @No_Of_Digits
--											set @len = @No_Of_Digits						
--									set @Emp_Code = REPLICATE ('0',@No_Of_Digits - @len) + @Emp_Code
--								end
--							else
--								begin
--									Select @Emp_Code =ISNULL(MAX(emp_code),0)+1 from T0080_EMP_MASTER where Cmp_ID=@Cmp_Id 
--									set @len = LEN(CAST (@emp_code as varchar(10)))		
--									if @len > @No_Of_Digits
--											set @len = @No_Of_Digits							
--									set @Emp_Code = REPLICATE ('0',@No_Of_Digits - @len) + @Emp_Code
--								end
--						end
--					else if @Is_Alpha_Numeric_Branchwise = 1  and @Is_Alpha_Numeric_Companywise = 0
--						begin
--							if @Branch_Id > 0 
--								begin
--									Select @Emp_Code =ISNULL(MAX(emp_code),0)+1 from T0080_EMP_MASTER where Cmp_ID=@Cmp_Id and Branch_ID=@Branch_Id	
--									set @len = LEN(CAST (@emp_code as varchar(10)))		
--									if @len > @No_Of_Digits
--											set @len = @No_Of_Digits
																
--									set @Emp_Code = REPLICATE ('0',@No_Of_Digits - @len) + @Emp_Code
--								end
--							else
--								begin
--									Select @Emp_Code =ISNULL(MAX(emp_code),0)+1 from T0080_EMP_MASTER where Cmp_ID=@Cmp_Id	
--									set @len = LEN(CAST (@emp_code as varchar(10)))		
--									if @len > @No_Of_Digits
--											set @len = @No_Of_Digits
																
--									set @Emp_Code = REPLICATE ('0',@No_Of_Digits - @len) + @Emp_Code
--								end
--						end
--					else if (@Is_Alpha_Numeric_Branchwise = 0  and @Is_Alpha_Numeric_Companywise = 1) or (@Is_Alpha_Numeric_Branchwise = 0 and @Is_Alpha_Numeric_Companywise = 0)
--						begin
							
--							Select @Emp_Code = ISNULL(MAX(emp_code),0)+1 from T0080_EMP_MASTER where Cmp_ID=@Cmp_Id	
							
--							set @len = LEN(CAST (@emp_code as varchar(10)))		
--							if @len > @No_Of_Digits
--											set @len = @No_Of_Digits
									
--									set @Emp_Code = REPLICATE ('0',@No_Of_Digits - @len) + @Emp_Code
--						end
--				End
--			Else If @Max_Emp_Code = 'Group_Company_Wise'
--				Begin
				
--					--Select @Emp_Code = ISNULL(MAX(emp_code),0)+1 from T0080_EMP_MASTER 
--					--Where Cmp_ID In (Select Cmp_ID From T0010_COMPANY_MASTER Where is_GroupOFCmp = 1)
						
--					--set @len = LEN(CAST (@emp_code as varchar(10)))		
--					--if @len > @No_Of_Digits
--					--				set @len = @No_Of_Digits
							
--					--		set @Emp_Code = REPLICATE ('0',@No_Of_Digits - @len) + @Emp_Code
--					--	end
--					If @Is_Alpha_Numeric_Branchwise = 1  and @Is_Alpha_Numeric_Companywise = 1
--						begin
--							if @Branch_Id > 0 
--								begin
--									Select @Emp_Code =ISNULL(MAX(emp_code),0)+1 from T0080_EMP_MASTER where Cmp_ID In (Select Cmp_ID From T0010_COMPANY_MASTER Where is_GroupOFCmp = 1) and Branch_ID=@Branch_Id
--									set @len = LEN(CAST (@emp_code as varchar(10)))		
--											if @len > @No_Of_Digits
--											set @len = @No_Of_Digits						
--									set @Emp_Code = REPLICATE ('0',@No_Of_Digits - @len) + @Emp_Code
--								end
--							else
--								begin
--									Select @Emp_Code =ISNULL(MAX(emp_code),0)+1 from T0080_EMP_MASTER where Cmp_ID=@Cmp_Id 
--									set @len = LEN(CAST (@emp_code as varchar(10)))		
--									if @len > @No_Of_Digits
--											set @len = @No_Of_Digits							
--									set @Emp_Code = REPLICATE ('0',@No_Of_Digits - @len) + @Emp_Code
--								end
--						end
--					else if @Is_Alpha_Numeric_Branchwise = 1  and @Is_Alpha_Numeric_Companywise = 0
--						begin
--							if @Branch_Id > 0 
--								begin
--									Select @Emp_Code =ISNULL(MAX(emp_code),0)+1 from T0080_EMP_MASTER where Cmp_ID In (Select Cmp_ID From T0010_COMPANY_MASTER Where is_GroupOFCmp = 1) and Branch_ID=@Branch_Id	
--									set @len = LEN(CAST (@emp_code as varchar(10)))		
--									if @len > @No_Of_Digits
--											set @len = @No_Of_Digits
																
--									set @Emp_Code = REPLICATE ('0',@No_Of_Digits - @len) + @Emp_Code
--								end
--							else
--								begin
--									Select @Emp_Code =ISNULL(MAX(emp_code),0)+1 from T0080_EMP_MASTER where Cmp_ID In (Select Cmp_ID From T0010_COMPANY_MASTER Where is_GroupOFCmp = 1)	
--									set @len = LEN(CAST (@emp_code as varchar(10)))		
--									if @len > @No_Of_Digits
--											set @len = @No_Of_Digits
																
--									set @Emp_Code = REPLICATE ('0',@No_Of_Digits - @len) + @Emp_Code
--								end
--						end
--					else if (@Is_Alpha_Numeric_Branchwise = 0  and @Is_Alpha_Numeric_Companywise = 1) or (@Is_Alpha_Numeric_Branchwise = 0 and @Is_Alpha_Numeric_Companywise = 0)
--						begin
							
--							Select @Emp_Code = ISNULL(MAX(emp_code),0)+1 from T0080_EMP_MASTER where Cmp_ID In (Select Cmp_ID From T0010_COMPANY_MASTER Where is_GroupOFCmp = 1)		
							
--							set @len = LEN(CAST (@emp_code as varchar(10)))		
--							if @len > @No_Of_Digits
--											set @len = @No_Of_Digits
									
--									set @Emp_Code = REPLICATE ('0',@No_Of_Digits - @len) + @Emp_Code
--						end
--				End
				
--		end
			
--	if @Cmp_Code is null 
--		set @Cmp_Code = ''
--		if @Is_Auto_Alpha_Numeric_Code = 1  
--		begin
--			if @Is_Alpha_Numeric_Companywise = 1 and  @Is_Alpha_Numeric_Branchwise = 1 
--			begin
--				Set @Alpha_Code = @Cmp_Code + @Branch_Code	
--			end
--			else if @Is_Alpha_Numeric_Companywise = 0 and  @Is_Alpha_Numeric_Branchwise = 1
--			begin
--				Set @Alpha_Code =  @Branch_Code	
--			end
--			else if @Is_Alpha_Numeric_Companywise = 1 and  @Is_Alpha_Numeric_Branchwise = 0
--			begin
--				Set @Alpha_Code =  @Cmp_Code
--			end
--			else
--			begin
--				Set @Alpha_Code = NULL
--			end
--		end
--		else
--		begin
--			set @Alpha_Code = NULL
--		end
--  	set @Get_Alpha_Code = @Alpha_Code
--	set @Get_Emp_Code = CAST(@Emp_Code as varchar(50))
--	Select @Alpha_Code as Alpha_Code,@Emp_Code as Emp_Code
    
--END




