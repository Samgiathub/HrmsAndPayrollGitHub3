

-- =============================================
-- Author:		<ANKIT>
-- Create date: <19122014,,>
-- Description:	<Description,,>
---25/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[Get_Employee_Code_TEMP]
 @Cmp_Id		numeric
,@Branch_Id		numeric
,@joiningDate	varchar(20) = ''
,@Get_Emp_Code	varchar(40) = '' output
,@Get_Alpha_Code	varchar(40) = '' Output
,@Is_Only_Emp_Code tinyint = 0
,@Desig_ID		numeric = 0
,@Cate_ID		numeric = 0
,@Type_ID		numeric = 0

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
	
    Select @Cmp_Code=isnull(Cmp_Code,''),@Is_Auto_Alpha_Numeric_Code=isnull(Is_Auto_Alpha_Numeric_Code,0)
		,@Is_Alpha_Numeric_Branchwise=isnull(Is_Alpha_Numeric_Branchwise,0),@No_Of_Digits=isnull(No_Of_Digit_Emp_Code,0),@Is_Alpha_Numeric_Companywise = ISNULL(Is_CompanyWise,0) 
		,@Is_Date_Wise = ISNULL(Is_DateWise,0),@is_JoiningDate_Wise = ISNULL(Is_JoiningDateWise,0),@Date_Format = ISNULL(DateFormat,'YYYYMMDD'),@is_ResetSequance = ISNULL(Reset_Sequance,0)
		,@Is_GroupOFCmp = ISNULL(Is_GroupOFCmp,0) ,@Max_Emp_Code = Max_Emp_Code	,@Sample_Emp_Code = Sample_Emp_Code --Ankit 12072014
    From T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@Cmp_Id
    
    
	declare @DayJoiningDate as varchar(2) 
	declare @MonthJoingDate as varchar(2)
	declare @DayCurrentDate as varchar(2) 
	declare @MonthCurrentDate as varchar(2) 
	set @DayJoiningDate  = ''
	set @MonthJoingDate = ''
	set @DayCurrentDate  = ''
	set @MonthCurrentDate  = ''

	
	DECLARE @CurSample Varchar(50)
	DECLARE @Sample_Code varchar(50)
		SET @Sample_Code = ''
		
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
					SELECT  @Branch_Code=Branch_Code, @Branch_Name = Branch_Name 
					FROM	T0030_BRANCH_MASTER WITH (NOLOCK) WHERE Cmp_ID=@Cmp_Id and Branch_ID=@Branch_Id
					    
					IF @BRANCH_CODE IS NULL
						SET @BRANCH_CODE = ''
					IF @BRANCH_NAME IS NULL
						SET @BRANCH_NAME = ''
					
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
			ELSE IF UPPER(@CurSample) = UPPER(@Date_Format)
				BEGIN
					IF @is_JoiningDate_Wise = 1 and  @joiningDate <> ''
						BEGIN
							IF DAY(@joiningDate) < 10
									set @DayJoiningDate = '0' + CONVERT(varchar(2), DAY(@joiningDate))
								else
									set @DayJoiningDate = CONVERT(varchar(2), DAY(@joiningDate))
									
							if Month(@joiningDate) < 10
									set @MonthJoingDate = '0' + CONVERT(varchar(2),Month(@joiningDate))
								else
									set  @MonthJoingDate = CONVERT(varchar(2), Month(@joiningDate))		
						end
					ELSE
						BEGIN
							IF DAY(GETDATE()) < 10
									set @DayCurrentDate = '0' + CONVERT(varchar(2), DAY(GETDATE()))
								else
									set @DayCurrentDate = Convert(varchar(2),DAY(GETDATE()))
									
							if Month(GETDATE()) < 10
									set @MonthCurrentDate = '0' + CONVERT(varchar(2),Month(GETDATE()))
								else
									set @MonthCurrentDate = Convert(varchar(2),Month(GETDATE()))
						END
					
					IF  @Date_Format = 'DDMM'	
						BEGIN
							IF @is_JoiningDate_Wise = 1 and  @joiningDate <> ''
								begin		
									set @Date_Code =  @DayJoiningDate + @MonthJoingDate
								end
							else if @is_JoiningDate_Wise = 0	 
								set @Date_Code =  @DayCurrentDate + @MonthCurrentDate
						END
					IF  @Date_Format = 'DDMMYY'	
						BEGIN
							if @is_JoiningDate_Wise = 1 and  @joiningDate <> ''
								set @Date_Code =   @DayJoiningDate + @MonthJoingDate +  substring(Convert(varchar(4),Year(@joiningDate)),3,2)
							else if @is_JoiningDate_Wise = 0	 
								set @Date_Code =  @DayCurrentDate + @MonthCurrentDate + substring(Convert(varchar(4),Year(GETDATE())),3,2)
						end
					ELSE IF @Date_Format = 'DDMMYYYY'
						BEGIN
							if @is_JoiningDate_Wise = 1 and  @joiningDate <> ''
								set @Date_Code =  @DayJoiningDate + @MonthJoingDate + CONVERT(varchar(4),Year(@joiningDate))
							else if @is_JoiningDate_Wise = 0	 
								set @Date_Code =  @DayCurrentDate + @MonthCurrentDate + CONVERT(varchar(4),Year(GETDATE()))
						END
					ELSE IF  @Date_Format = 'MMDD'	
						BEGIN
							IF @is_JoiningDate_Wise = 1 and  @joiningDate <> ''
								set @Date_Code =  @MonthJoingDate + @DayJoiningDate
							ELSE IF @is_JoiningDate_Wise = 0	 
								set @Date_Code =  @MonthCurrentDate  + @DayCurrentDate
						END
					ELSE IF @Date_Format = 'MMYY'
						BEGIN
							if @is_JoiningDate_Wise = 1 and  @joiningDate <> ''
								set @Date_Code =  @MonthJoingDate +  substring(Convert(varchar(4),Year(@joiningDate)),3,2)
							else if @is_JoiningDate_Wise = 0	 
								set @Date_Code =  @MonthCurrentDate + substring(Convert(varchar(4),Year(GETDATE())),3,2)
						END	
					ELSE IF @Date_Format = 'MMYYYY'
						BEGIN
							if @is_JoiningDate_Wise = 1 and  @joiningDate <> ''
								set @Date_Code =  @MonthJoingDate + CONVERT(varchar(4),Year(@joiningDate))
							else if @is_JoiningDate_Wise = 0	 
								set @Date_Code =  @MonthCurrentDate + convert(varchar(4),Year(GETDATE()))
						end
					ELSE IF @Date_Format = 'MMDDYY'
						BEGIN
							if @is_JoiningDate_Wise = 1 and  @joiningDate <> ''
								set @Date_Code =  @MonthJoingDate + @DayJoiningDate + substring(Convert(varchar(4),Year(@joiningDate)),3,2)
							else if @is_JoiningDate_Wise = 0	 
								set @Date_Code =  @MonthCurrentDate + @DayCurrentDate + substring(Convert(varchar(4),Year(GETDATE())),3,2)
						end
					ELSE IF @Date_Format = 'MMDDYYYY'
						BEGIN
							if @is_JoiningDate_Wise = 1 and  @joiningDate <> ''
								set @Date_Code =  @MonthJoingDate + @DayJoiningDate+ Convert(varchar(4),Year(@joiningDate))
							else if @is_JoiningDate_Wise = 0	 
								set @Date_Code =  @MonthCurrentDate + @DayCurrentDate + Convert(varchar(4),Year(GETDATE()))
						end
					ELSE IF @Date_Format = 'MMYYDD'
						BEGIN
							if @is_JoiningDate_Wise = 1 and  @joiningDate <> ''
								set @Date_Code =  @MonthJoingDate + substring(Convert(varchar(4),Year(@joiningDate)),3,2) + @DayJoiningDate
							else if @is_JoiningDate_Wise = 0	 
								set @Date_Code =  @MonthCurrentDate + substring(Convert(varchar(4),Year(GETDATE())),3,2) + @DayCurrentDate
						end
					ELSE IF @Date_Format = 'MMYYYYDD'
						BEGIN
							if @is_JoiningDate_Wise = 1 and  @joiningDate <> ''
								set @Date_Code =  @MonthJoingDate + Convert(varchar(4),Year(@joiningDate)) + @DayJoiningDate
							else if @is_JoiningDate_Wise = 0	 
								set @Date_Code =  @MonthCurrentDate + Convert(varchar(4),Year(GETDATE())) + @DayCurrentDate
						end
					ELSE IF @Date_Format = 'YYMM'
						BEGIN
						
							if @is_JoiningDate_Wise = 1 and  @joiningDate <> ''
								set @Date_Code =  substring(Convert(varchar(4),Year(@joiningDate)),3,2) + @MonthJoingDate
							else if @is_JoiningDate_Wise = 0	 
								set @Date_Code =  substring(Convert(varchar(4),Year(GETDATE())),3,2) + @MonthCurrentDate
						end
					ELSE IF @Date_Format = 'YYDDMM'
						BEGIN
						
							if @is_JoiningDate_Wise = 1 and  @joiningDate <> ''
								set @Date_Code =  substring(Convert(varchar(4),Year(@joiningDate)),3,2) + @DayJoiningDate + @MonthJoingDate
							else if @is_JoiningDate_Wise = 0	 
								set @Date_Code =  substring(Convert(varchar(4),Year(GETDATE())),3,2) + @DayCurrentDate + @MonthCurrentDate
						end
					ELSE IF @Date_Format = 'YYMMDD'
						BEGIN
						
							if @is_JoiningDate_Wise = 1 and  @joiningDate <> ''
								set @Date_Code =  substring(Convert(varchar(4),Year(@joiningDate)),3,2) + @MonthJoingDate + @DayJoiningDate
							else if @is_JoiningDate_Wise = 0	 
								set @Date_Code =  substring(Convert(varchar(4),Year(GETDATE())),3,2) + @MonthCurrentDate + @DayCurrentDate
						end
					ELSE IF @Date_Format = 'YYYYMM'
						BEGIN
							if @is_JoiningDate_Wise = 1 and  @joiningDate <> ''
								set @Date_Code =  CONVERT(varchar(4),Year(@joiningDate)) + @MonthJoingDate
							else if @is_JoiningDate_Wise = 0	 
								set @Date_Code =  Convert(varchar(4),Year(GETDATE())) + @MonthCurrentDate
						end
					ELSE IF @Date_Format = 'YYYYMMDD'
						BEGIN
							if @is_JoiningDate_Wise = 1 and  @joiningDate <> ''
								set @Date_Code =  CONVERT(varchar(4),Year(@joiningDate)) + @MonthJoingDate + @DayJoiningDate
							else if @is_JoiningDate_Wise = 0	 
								set @Date_Code =  CONVERT(varchar(4),Year(GETDATE()))  + @MonthCurrentDate+  @DayCurrentDate
						end
					ELSE IF @Date_Format = 'YYYYDDMM'
						BEGIN
							if @is_JoiningDate_Wise = 1 and  @joiningDate <> ''
								set @Date_Code =  CONVERT(varchar(4),Year(@joiningDate))+ @DayJoiningDate + @MonthJoingDate
							else if @is_JoiningDate_Wise = 0	 
								set @Date_Code =  convert(varchar(4),Year(GETDATE())) + @DayCurrentDate + @MonthCurrentDate
						END	
				END
				
				
			FETCH NEXT FROM CusrSample into @CurSample
		END
	close CusrSample         
	deallocate CusrSample



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
																	Select @Emp_Code = CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) from T0080_EMP_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_Id and Branch_ID=@Branch_Id  
																	and  SUBSTRING(isnull(Code_Date,Convert(varchar(20),00)), PATINDEX('%MM%',isnull(Code_Date_Format,'MM')),2)  = Month(@joiningDate)
																	and  Year(System_Date) = Year(@joiningDate)	
																end
															else
																begin
																	Select @Emp_Code = CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) from T0080_EMP_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_Id and Branch_ID=@Branch_Id  
																end
														end
													else
														begin
															Select @Emp_Code = CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) from T0080_EMP_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_Id and Branch_ID=@Branch_Id  
															and  SUBSTRING(isnull(Code_Date,Convert(varchar(20),00)), PATINDEX('%MM%',isnull(Code_Date_Format,'MM')),2)  = Month(GETDATE())
															and  Year(System_Date) = Year(GETDATE())	
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
																	Select @Emp_Code = CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) from T0080_EMP_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_Id  
																	and  SUBSTRING(isnull(Code_Date,Convert(varchar(20),00)), PATINDEX('%MM%',isnull(Code_Date_Format,'MM')),2)  = Month(@joiningDate)
																	and  Year(System_Date) = Year(@joiningDate)	
																end
															else
																begin
																	Select @Emp_Code = CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) from T0080_EMP_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_Id   
																end
													end
												else
													begin
													
														Select @Emp_Code = CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) from T0080_EMP_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_Id 
														and  SUBSTRING(isnull(Code_Date,Convert(varchar(20),00)), PATINDEX('%MM%',isnull(Code_Date_Format,'MM')),2)  = Month(GETDATE())		
														and  Year(System_Date) = Year(GETDATE())
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
												Select @Emp_Code = CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) from T0080_EMP_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_Id and Branch_ID=@Branch_Id  
												
												set @len = LEN(CAST (@emp_code as varchar(10)))
													
													if @len > @No_Of_Digits
														set @len = @No_Of_Digits
														
													set @Emp_Code = @Date_Code + REPLICATE ('0',@No_Of_Digits - @len) + @Emp_Code
											end	
										else
											begin
												Select @Emp_Code = CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) from T0080_EMP_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_Id 
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
															Select @Emp_Code = CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) from T0080_EMP_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_Id and Branch_ID=@Branch_Id 
															and  SUBSTRING(isnull(Code_Date,Convert(varchar(20),00)), PATINDEX('%MM%',isnull(Code_Date_Format,'MM')),2)  = Month(@joiningDate)		
															and  Year(System_Date) = Year(@joiningDate)
														end
													else
														begin
															Select @Emp_Code = CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) from T0080_EMP_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_Id and Branch_ID=@Branch_Id 
														end
													end
												else
													begin
														Select @Emp_Code = CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) from T0080_EMP_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_Id and Branch_ID=@Branch_Id 
														and  SUBSTRING(isnull(Code_Date,Convert(varchar(20),00)), PATINDEX('%MM%',isnull(Code_Date_Format,'MM')),2)  = Month(GETDATE())		
														and  Year(System_Date) = Year(GETDATE())		
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
															Select @Emp_Code = CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) from T0080_EMP_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_Id  
															and  SUBSTRING(isnull(Code_Date,Convert(varchar(20),00)), PATINDEX('%MM%',isnull(Code_Date_Format,'MM')),2)  = 	Month(@joiningDate)		
															and  Year(System_Date) = Year(@joiningDate)
														end
													else
														Begin
															Select @Emp_Code = CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) from T0080_EMP_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_Id  
														end	
														
												end
											else
												begin
													Select @Emp_Code = CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) from T0080_EMP_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_Id  
													and  SUBSTRING(isnull(Code_Date,Convert(varchar(20),00)), PATINDEX('%MM%',isnull(Code_Date_Format,'MM')),2)  = Month(GETDATE())		
													and  Year(System_Date) = Year(GETDATE())
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
												Select @Emp_Code = CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) from T0080_EMP_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_Id and Branch_ID=@Branch_Id		
												
												set @len = LEN(CAST (@emp_code as varchar(10)))
													
													if @len > @No_Of_Digits
														set @len = @No_Of_Digits
														
													set @Emp_Code = @Date_Code + REPLICATE ('0',@No_Of_Digits - @len) + @Emp_Code
											end	
										else
											begin
												Select @Emp_Code =  CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) from T0080_EMP_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_Id 		
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
													Select @Emp_Code = CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1)from T0080_EMP_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_Id	
													and SUBSTRING(isnull(Code_Date,Convert(varchar(20),00)), PATINDEX('%MM%',isnull(Code_Date_Format,'MM')),2)  = Month(@joiningDate)
													and  Year(System_Date) = Year(@joiningDate)
												end
											else
												begin
													Select @Emp_Code = CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1)from T0080_EMP_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_Id	
												end
										end
									else
										begin
											Select @Emp_Code = CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1)from T0080_EMP_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_Id	
											and SUBSTRING(isnull(Code_Date,Convert(varchar(20),00)), PATINDEX('%MM%',isnull(Code_Date_Format,'MM')),2)  = Month(GETDATE())
											and  Year(System_Date) = Year(GETDATE())
										end
												set @len = LEN(CAST (@emp_code as varchar(10)))
													
													if @len > @No_Of_Digits
														set @len = @No_Of_Digits
														
													set @Emp_Code = @Date_Code + REPLICATE ('0',@No_Of_Digits - @len) + @Emp_Code
									end
								else
									begin
										Select @Emp_Code = CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) from T0080_EMP_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_Id	
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
																Select @Emp_Code = CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) from T0080_EMP_MASTER WITH (NOLOCK)
																Where Cmp_ID In (Select Cmp_ID From T0010_COMPANY_MASTER WITH (NOLOCK) Where is_GroupOFCmp = 1)
											
																and  SUBSTRING(isnull(Code_Date,Convert(varchar(20),00)), PATINDEX('%MM%',isnull(Code_Date_Format,'MM')),2)  = Month(@joiningDate)
																and  Year(System_Date) = Year(@joiningDate)	
															end
														else
															begin
																Select @Emp_Code = CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) from T0080_EMP_MASTER WITH (NOLOCK)
																Where Cmp_ID In (Select Cmp_ID From T0010_COMPANY_MASTER WITH (NOLOCK) Where is_GroupOFCmp = 1)
											
															end
													end
												else
													begin
													
														Select @Emp_Code = CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) from T0080_EMP_MASTER WITH (NOLOCK)
														Where Cmp_ID In (Select Cmp_ID From T0010_COMPANY_MASTER WITH (NOLOCK) Where is_GroupOFCmp = 1)
												
														and  SUBSTRING(isnull(Code_Date,Convert(varchar(20),00)), PATINDEX('%MM%',isnull(Code_Date_Format,'MM')),2)  = Month(GETDATE())		
														and  Year(System_Date) = Year(GETDATE())
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
																	Select @Emp_Code = CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) from T0080_EMP_MASTER WITH (NOLOCK) where Cmp_ID In (Select Cmp_ID From T0010_COMPANY_MASTER WITH (NOLOCK) Where is_GroupOFCmp = 1) 
																	and  SUBSTRING(isnull(Code_Date,Convert(varchar(20),00)), PATINDEX('%MM%',isnull(Code_Date_Format,'MM')),2)  = Month(@joiningDate)
																	and  Year(System_Date) = Year(@joiningDate)	
																end
															else
																begin
																
																	Select @Emp_Code = CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) from T0080_EMP_MASTER WITH (NOLOCK) where Cmp_ID In (Select Cmp_ID From T0010_COMPANY_MASTER WITH (NOLOCK) Where is_GroupOFCmp = 1)   
																end
													end
												else
													begin
													
														Select @Emp_Code = CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) from T0080_EMP_MASTER WITH (NOLOCK) where Cmp_ID In (Select Cmp_ID From T0010_COMPANY_MASTER WITH (NOLOCK) Where is_GroupOFCmp = 1) 
														and  SUBSTRING(isnull(Code_Date,Convert(varchar(20),00)), PATINDEX('%MM%',isnull(Code_Date_Format,'MM')),2)  = Month(GETDATE())		
														and  Year(System_Date) = Year(GETDATE())
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
												Select @Emp_Code = CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) from T0080_EMP_MASTER WITH (NOLOCK) 
												Where Cmp_ID In (Select Cmp_ID From T0010_COMPANY_MASTER WITH (NOLOCK) Where is_GroupOFCmp = 1)
												
												set @len = LEN(CAST (@emp_code as varchar(10)))
													
													if @len > @No_Of_Digits
														set @len = @No_Of_Digits
													
													set @Emp_Code = @Date_Code + REPLICATE ('0',@No_Of_Digits - @len) + @Emp_Code
										
											end
										else
											begin
												Select @Emp_Code = CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) from T0080_EMP_MASTER WITH (NOLOCK) where Cmp_ID In (Select Cmp_ID From T0010_COMPANY_MASTER WITH (NOLOCK) Where is_GroupOFCmp = 1)
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
																Select @Emp_Code = CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) from T0080_EMP_MASTER WITH (NOLOCK)
																Where Cmp_ID In (Select Cmp_ID From T0010_COMPANY_MASTER WITH (NOLOCK) Where is_GroupOFCmp = 1)
																and  SUBSTRING(isnull(Code_Date,Convert(varchar(20),00)), PATINDEX('%MM%',isnull(Code_Date_Format,'MM')),2)  = 	Month(@joiningDate)		
																and  Year(System_Date) = Year(@joiningDate)
															end
														else
															Begin
																Select @Emp_Code = CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) from T0080_EMP_MASTER WITH (NOLOCK)
																Where Cmp_ID In (Select Cmp_ID From T0010_COMPANY_MASTER WITH (NOLOCK) Where is_GroupOFCmp = 1)
															end	
															
													end
												else
													begin
														Select @Emp_Code = CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) from T0080_EMP_MASTER WITH (NOLOCK)
														Where Cmp_ID In (Select Cmp_ID From T0010_COMPANY_MASTER WITH (NOLOCK) Where is_GroupOFCmp = 1)
														and  SUBSTRING(isnull(Code_Date,Convert(varchar(20),00)), PATINDEX('%MM%',isnull(Code_Date_Format,'MM')),2)  = Month(GETDATE())		
														and  Year(System_Date) = Year(GETDATE())
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
															Select @Emp_Code = CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) from T0080_EMP_MASTER WITH (NOLOCK) where Cmp_ID In (Select Cmp_ID From T0010_COMPANY_MASTER WITH (NOLOCK) Where is_GroupOFCmp = 1) 
															and  SUBSTRING(isnull(Code_Date,Convert(varchar(20),00)), PATINDEX('%MM%',isnull(Code_Date_Format,'MM')),2)  = 	Month(@joiningDate)		
															and  Year(System_Date) = Year(@joiningDate)
														end
													else
														Begin
															Select @Emp_Code = CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) from T0080_EMP_MASTER WITH (NOLOCK) where Cmp_ID In (Select Cmp_ID From T0010_COMPANY_MASTER WITH (NOLOCK) Where is_GroupOFCmp = 1) 
														end	
														
												end
											else
												begin
													Select @Emp_Code = CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) from T0080_EMP_MASTER WITH (NOLOCK) where Cmp_ID In (Select Cmp_ID From T0010_COMPANY_MASTER WITH (NOLOCK) Where is_GroupOFCmp = 1)  
													and  SUBSTRING(isnull(Code_Date,Convert(varchar(20),00)), PATINDEX('%MM%',isnull(Code_Date_Format,'MM')),2)  = Month(GETDATE())		
													and  Year(System_Date) = Year(GETDATE())
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
												Select @Emp_Code =  CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) from T0080_EMP_MASTER WITH (NOLOCK)
												Where Cmp_ID In (Select Cmp_ID From T0010_COMPANY_MASTER WITH (NOLOCK) Where is_GroupOFCmp = 1)
												
												set @len = LEN(CAST (@emp_code as varchar(10)))
													
													if @len > @No_Of_Digits
														set @len = @No_Of_Digits
														
													set @Emp_Code = @Date_Code + REPLICATE ('0',@No_Of_Digits - @len) + @Emp_Code
											end
										else
											begin
												Select @Emp_Code =  CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) from T0080_EMP_MASTER WITH (NOLOCK) where Cmp_ID In (Select Cmp_ID From T0010_COMPANY_MASTER WITH (NOLOCK) Where is_GroupOFCmp = 1)		
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
													Select @Emp_Code = CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1)from T0080_EMP_MASTER WITH (NOLOCK)
													Where Cmp_ID In (Select Cmp_ID From T0010_COMPANY_MASTER WITH (NOLOCK) Where is_GroupOFCmp = 1)
													and SUBSTRING(isnull(Code_Date,Convert(varchar(20),00)), PATINDEX('%MM%',isnull(Code_Date_Format,'MM')),2)  = Month(@joiningDate)
													and  Year(System_Date) = Year(@joiningDate)
												end
											else
												begin
													Select @Emp_Code = CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1)from T0080_EMP_MASTER WITH (NOLOCK)
													Where Cmp_ID In (Select Cmp_ID From T0010_COMPANY_MASTER WITH (NOLOCK) Where is_GroupOFCmp = 1)
												end
										end
									else
										begin
											Select @Emp_Code = CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1)from T0080_EMP_MASTER WITH (NOLOCK)
											Where Cmp_ID In (Select Cmp_ID From T0010_COMPANY_MASTER WITH (NOLOCK) Where is_GroupOFCmp = 1)
											and SUBSTRING(isnull(Code_Date,Convert(varchar(20),00)), PATINDEX('%MM%',isnull(Code_Date_Format,'MM')),2)  = Month(GETDATE())
											and  Year(System_Date) = Year(GETDATE())
										end
												set @len = LEN(CAST (@emp_code as varchar(10)))
													
													if @len > @No_Of_Digits
														set @len = @No_Of_Digits
														
													set @Emp_Code = @Date_Code + REPLICATE ('0',@No_Of_Digits - @len) + @Emp_Code
									end
								else
									begin
										Select @Emp_Code = CONVERT(varchar(20),ISNULL(MAX(emp_code),0)+1) from T0080_EMP_MASTER WITH (NOLOCK)
										Where Cmp_ID In (Select Cmp_ID From T0010_COMPANY_MASTER WITH (NOLOCK) Where is_GroupOFCmp = 1)
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
									Select @Emp_Code =ISNULL(MAX(emp_code),0)+1 from T0080_EMP_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_Id and Branch_ID=@Branch_Id
									set @len = LEN(CAST (@emp_code as varchar(10)))		
											if @len > @No_Of_Digits
											set @len = @No_Of_Digits						
									set @Emp_Code = REPLICATE ('0',@No_Of_Digits - @len) + @Emp_Code
								end
							else
								begin
									Select @Emp_Code =ISNULL(MAX(emp_code),0)+1 from T0080_EMP_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_Id 
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
									Select @Emp_Code =ISNULL(MAX(emp_code),0)+1 from T0080_EMP_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_Id and Branch_ID=@Branch_Id	
									set @len = LEN(CAST (@emp_code as varchar(10)))		
									if @len > @No_Of_Digits
											set @len = @No_Of_Digits
																
									set @Emp_Code = REPLICATE ('0',@No_Of_Digits - @len) + @Emp_Code
								end
							else
								begin
									Select @Emp_Code =ISNULL(MAX(emp_code),0)+1 from T0080_EMP_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_Id	
									set @len = LEN(CAST (@emp_code as varchar(10)))		
									if @len > @No_Of_Digits
											set @len = @No_Of_Digits
																
									set @Emp_Code = REPLICATE ('0',@No_Of_Digits - @len) + @Emp_Code
								end
						end
					else if (@Is_Alpha_Numeric_Branchwise = 0  and @Is_Alpha_Numeric_Companywise = 1) or (@Is_Alpha_Numeric_Branchwise = 0 and @Is_Alpha_Numeric_Companywise = 0)
						begin
							
							Select @Emp_Code = ISNULL(MAX(emp_code),0)+1 from T0080_EMP_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_Id	
							
							set @len = LEN(CAST (@emp_code as varchar(10)))		
							if @len > @No_Of_Digits
											set @len = @No_Of_Digits
									
									set @Emp_Code = REPLICATE ('0',@No_Of_Digits - @len) + @Emp_Code
						end
				End
			Else If @Max_Emp_Code = 'Group_Company_Wise'
				Begin
				
					--Select @Emp_Code = ISNULL(MAX(emp_code),0)+1 from T0080_EMP_MASTER 
					--Where Cmp_ID In (Select Cmp_ID From T0010_COMPANY_MASTER Where is_GroupOFCmp = 1)
						
					--set @len = LEN(CAST (@emp_code as varchar(10)))		
					--if @len > @No_Of_Digits
					--				set @len = @No_Of_Digits
							
					--		set @Emp_Code = REPLICATE ('0',@No_Of_Digits - @len) + @Emp_Code
					--	end
					If @Is_Alpha_Numeric_Branchwise = 1  and @Is_Alpha_Numeric_Companywise = 1
						begin
							if @Branch_Id > 0 
								begin
									Select @Emp_Code =ISNULL(MAX(emp_code),0)+1 from T0080_EMP_MASTER WITH (NOLOCK) where Cmp_ID In (Select Cmp_ID From T0010_COMPANY_MASTER WITH (NOLOCK) Where is_GroupOFCmp = 1) and Branch_ID=@Branch_Id
									set @len = LEN(CAST (@emp_code as varchar(10)))		
											if @len > @No_Of_Digits
											set @len = @No_Of_Digits						
									set @Emp_Code = REPLICATE ('0',@No_Of_Digits - @len) + @Emp_Code
								end
							else
								begin
									Select @Emp_Code =ISNULL(MAX(emp_code),0)+1 from T0080_EMP_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_Id 
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
									Select @Emp_Code =ISNULL(MAX(emp_code),0)+1 from T0080_EMP_MASTER WITH (NOLOCK) where Cmp_ID In (Select Cmp_ID From T0010_COMPANY_MASTER WITH (NOLOCK) Where is_GroupOFCmp = 1) and Branch_ID=@Branch_Id	
									set @len = LEN(CAST (@emp_code as varchar(10)))		
									if @len > @No_Of_Digits
											set @len = @No_Of_Digits
																
									set @Emp_Code = REPLICATE ('0',@No_Of_Digits - @len) + @Emp_Code
								end
							else
								begin
									Select @Emp_Code =ISNULL(MAX(emp_code),0)+1 from T0080_EMP_MASTER WITH (NOLOCK) where Cmp_ID In (Select Cmp_ID From T0010_COMPANY_MASTER WITH (NOLOCK) Where is_GroupOFCmp = 1)	
									set @len = LEN(CAST (@emp_code as varchar(10)))		
									if @len > @No_Of_Digits
											set @len = @No_Of_Digits
																
									set @Emp_Code = REPLICATE ('0',@No_Of_Digits - @len) + @Emp_Code
								end
						end
					else if (@Is_Alpha_Numeric_Branchwise = 0  and @Is_Alpha_Numeric_Companywise = 1) or (@Is_Alpha_Numeric_Branchwise = 0 and @Is_Alpha_Numeric_Companywise = 0)
						begin
							
							Select @Emp_Code = ISNULL(MAX(emp_code),0)+1 from T0080_EMP_MASTER WITH (NOLOCK) where Cmp_ID In (Select Cmp_ID From T0010_COMPANY_MASTER WITH (NOLOCK) Where is_GroupOFCmp = 1)		
							
							set @len = LEN(CAST (@emp_code as varchar(10)))		
							if @len > @No_Of_Digits
											set @len = @No_Of_Digits
									
									set @Emp_Code = REPLICATE ('0',@No_Of_Digits - @len) + @Emp_Code
						end
				End
				
		end
			
	set @Get_Alpha_Code = @Alpha_Code
	set @Get_Emp_Code = CAST(@Emp_Code as varchar(50))
	
	Select @Sample_Code as Alpha_Code,@Emp_Code as Emp_Code
    
END




