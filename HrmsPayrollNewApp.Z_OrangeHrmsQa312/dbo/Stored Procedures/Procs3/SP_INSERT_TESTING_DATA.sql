



---25/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_INSERT_TESTING_DATA]
	@CMP_ID		NUMERIC ,
	@BRANCH_ID	NUMERIC,
	@FORM		VARCHAR(20)='EMP MASTER',
	@DATABASE	varchar(20)='PAYROLL_TDS'	
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON 
	
	DECLARE @EMP_NAME VARCHAR(100)
	DECLARE @GRADE_NAME VARCHAR(100)
	DECLARE @DEPT_NAME	VARCHAR(100)
	DECLARE @DESIG_NAME VARCHAR(100)
	DECLARE @TYPE_NAME	VARCHAR(100)
	
	DECLARE @JOIN_DATE	DATETIME
	DECLARE @BASIC_SLARY	NUMERIC

	DECLARE @Emp_ID	NUMERIC	
	DECLARE @Increment_ID	NUMERIC
	DECLARE @GRD_ID	NUMERIC 
	DECLARE @TYPE_ID	NUMERIC 
	DECLARE @DESIG_ID	NUMERIC 
	DECLARE @DEPT_ID	NUMERIC
	DECLARE @SHIFT_ID	NUMERIC 
	DECLARE @EMP_CODE	NUMERIC 
	DECLARE @INITIAL	VARCHAR(5)
    DECLARE @Emp_First_Name varchar(100)
    DECLARE @Emp_Second_Name varchar(100)
    DECLARE @Emp_Last_Name	varchar(100)
	DECLARE @Curr_ID		numeric(18,0)
    DECLARE @Date_Of_Join	datetime
    DECLARE @Date_Of_Birth  DATETIME 
    DECLARE @Marital_Status varchar(20)
    DECLARE @Gender			char(1)
    DECLARE @Loc_ID			numeric(18,0)
    DECLARE @Street_1		varchar(250)
    DECLARE @City			varchar(30)
    DECLARE @State			varchar(20)
    DECLARE @Zip_code		varchar(20)
    DECLARE @Home_Tel_no	varchar(30)
    DECLARE @Mobile_No		varchar(30)
    DECLARE @Work_Tel_No	varchar(30)
    DECLARE @Work_Email		varchar(50)
    DECLARE @Other_Email	varchar(50)
    DECLARE @Present_Street varchar(250)
    DECLARE @Present_City   varchar(30)
    DECLARE @Present_State  varchar(30)
    DECLARE @Present_Post_Box varchar(20)
    DECLARE @Basic_Salary	numeric(18,2)
	DECLARE @AD_ID			Numeric
	DECLARE @AD_FLAG		Char(1)
	DECLARE @AD_MODE		Varchar(10)
	DECLARE @AD_PERCENTAGE	numeric(5,2)
	DECLARE @AD_AMOUNT		numeric(18,2)
	DECLARE @AD_MAX_LIMIT	numeric
	
    

    set @Street_1		=''
    set @City			=''
    set @State			=''
    set @Zip_code		=''
    set @Home_Tel_no	=''
    set @Mobile_No		=''
    set @Work_Tel_No	=''
    set @Work_Email		=''
    set @Other_Email	=''
    set @Present_Street =''
    set @Present_City   =''
    set @Present_State  =''
    set @Present_Post_Box  =''

	IF @DATABASE = 'PAYROLL_TDS'
		BEGIN
				IF @FORM = 'EMP MASTER'	
					BEGIN
							DECLARE CUR_EMP CURSOR FOR 
							select emp_name,Grade_Name,Join_Date,Basic_rate,DEPT_NAME,DESIG_NAME,TYPE_NAME 
									,GENDER,MARTIAL_sTATUS
							from [payroll_TDS].dbo.get_Emp_master order by code						
							--from [payroll].dbo.get_Emp_master where is_left is null	order by code
							OPEN CUR_EMP
							FETCH NEXT FROM CUR_EMP INTO @EMP_NAME,@GRADE_NAME,@Date_Of_Join,@Basic_Salary,@DEPT_NAME,@DESIG_NAME,@TYPE_NAME,@GENDER,@MARITAL_STATUS
							while @@Fetch_Status = 0
								BEGIN
									SELECT @EMP_CODE = ISNULL(MAX(EMP_CODE),0)+ 1 FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE CMP_ID = @CMP_ID
									IF @GENDER ='M' 
										SET @INITIAL ='Mr.'
									else if @gender ='F' and @Marital_Status ='M'
										set @Initial ='Mrs.'
									else if @gender ='F' and @Marital_Status ='U'
										set @Initial ='Miss.'
									
									set @Emp_First_Name = substring(@Emp_Name,1,charindex(' ',@Emp_Name,1)) 
									set @Emp_Second_NAme = ''
									if charindex(' ',@Emp_Name,1) >0
										set @Emp_last_Name = substring(@Emp_Name,charindex(' ',@Emp_Name,1) +1,len(@Emp_Name))
									else
										set @Emp_last_Name = ''
									
									set @Emp_ID = 0
									set @Increment_Id = 0
									select @Grd_ID =grd_ID from T0040_Grade_MAster WITH (NOLOCK) where cmp_ID = @Cmp_ID and Grd_Name =@Grade_Name
									select @Dept_ID =Dept_ID from T0040_Department_Master WITH (NOLOCK) where cmp_ID = @Cmp_ID and Dept_Name =@Dept_Name
									select @Desig_ID =Desig_ID from T0040_Designation_Master WITH (NOLOCK) where cmp_ID = @Cmp_ID and Desig_Name =@Desig_Name
									select @Type_ID =Type_Id from T0040_Type_Master WITH (NOLOCK) where cmp_ID = @Cmp_ID and Type_Name =@Type_Name
									
									select @Shift_ID = min(Shift_ID) From T0040_Shift_Master WITH (NOLOCK) where cmp_ID =@Cmp_ID
									if @Emp_First_Name <> '' and @Emp_Last_Name <> ''
										begin
												EXEC P0080_EMP_MASTER @Emp_ID 	output 
												,@Cmp_ID		  ,@Branch_ID		 ,NULL   ,@Grd_ID		
												,@Dept_ID		,@Desig_Id			,@Type_ID			,@Shift_ID		
												,NULL   ,@Increment_ID output  ,@Emp_code		  ,@Initial		  ,@Emp_First_Name 	  ,@Emp_Second_Name 
												   ,@Emp_Last_Name	  ,@Curr_ID		  ,@Date_Of_Join	  ,''		  ,''  ,''  ,''  ,@Date_Of_Birth    ,@Marital_Status 
												   ,@Gender		  ,NULL  ,'INDIAN'  ,@Loc_ID		  ,@Street_1		  ,@City		  ,@State		  ,@Zip_code		
												   ,@Home_Tel_no	  ,@Mobile_No		  ,@Work_Tel_No	  ,@Work_Email		  ,@Other_Email	  ,@Present_Street 
												   ,@Present_City     ,@Present_State    ,@Present_Post_Box   ,0  ,@Basic_Salary	  ,''  ,'Monthly'
												   ,'Day'   ,'Transfer'   ,'Ac No '    ,0		   ,'00:00'   ,'00:00'   ,0   ,1   ,1   ,0   ,'I'
												   
												
												
												Declare Cur_Ad cursor for
												select AD_ID,AD_Flag,AD_Mode,AD_Percentage,AD_max_Limit,AD_aMOUNT From T0050_AD_Master WITH (NOLOCK) where Cmp_ID = @Cmp_ID 
												open cur_ad
												Fetch next from cur_AD into @AD_ID,@AD_Flag ,@AD_Mode,@AD_Percentage,@AD_max_Limit,@AD_AMOUNT
												while @@fetch_Status = 0
													begin
														exec dbo.P0100_EMP_EARN_DEDUCTION 0,@Emp_ID,@Cmp_ID,@AD_ID,@Increment_ID,@Date_OF_Join,@AD_Flag,@AD_Mode,@AD_Percentage,@AD_Amount,@AD_Max_Limit,'I'	
														Fetch next from cur_AD into @AD_ID,@AD_Flag ,@AD_Mode,@AD_Percentage,@AD_max_Limit,@AD_AMOUNT
													end
												close cur_Ad
												deallocate cur_Ad
												   
										end   
								
									FETCH NEXT FROM CUR_EMP INTO @EMP_NAME,@GRADE_NAME,@Date_Of_Join,@Basic_Salary,@DEPT_NAME,@DESIG_NAME,@TYPE_NAME,@GENDER,@MARITAL_STATUS
								END
							CLOSE CUR_EMP
							DEALLOCATE CUR_EMP	
					END
				else if @Form ='PT'
					begin
						if Year(GetDATE()) > 2020
						BEGIN
							exec P0040_PROFESSIONAL_SETTING @Cmp_Id,@Branch_ID,0,'01-jan-2020',1,'12000','12999',200,'I'
							exec P0040_PROFESSIONAL_SETTING @Cmp_Id,@Branch_ID,0,'01-jan-2020',1,'12000','0',0,'I'
						END
						else
						BEGIN
							exec P0040_PROFESSIONAL_SETTING @Cmp_Id,@Branch_ID,0,'01-jan-2008',1,'3000','5999',20,'I'
							exec P0040_PROFESSIONAL_SETTING @Cmp_Id,@Branch_ID,0,'01-jan-2008',1,'6000','8999',80,'I'
							exec P0040_PROFESSIONAL_SETTING @Cmp_Id,@Branch_ID,0,'01-jan-2008',1,'9000','12999',150,'I'
							exec P0040_PROFESSIONAL_SETTING @Cmp_Id,@Branch_ID,0,'01-jan-2008',1,'12000','0',200,'I'
						END
						
							
					end	
				else if @FORM ='DEPARTMENT'
					BEGIN
						DECLARE CUR_DEPT CURSOR FOR 
							select DISTINCT DEPT_NAME 
							from [payroll_TDS].dbo.DEPARTMENT_MASTER 
							--from [payroll].dbo.DEPARTMENT_MASTER 
							OPEN CUR_DEPT
							FETCH NEXT FROM CUR_DEPT INTO @DEPT_NAME
							while @@Fetch_Status = 0
								BEGIN
									EXEC P0040_DEPARTMENT_MASTER 0 ,@CMP_ID,@DEPT_NAME,0,'I'
									FETCH NEXT FROM CUR_DEPT INTO @DEPT_NAME
								END
							CLOSE CUR_DEPT
							DEALLOCATE CUR_DEPT
									
						
					END
				else if @FORM ='DESIGNATION'
					BEGIN
						DECLARE CUR_DESIG CURSOR FOR 
							select DISTINCT DESIG_NAME
							--from [payroll].dbo.DESIGNATION_MASTER 
							from [payroll_TDS].dbo.DESIGNATION_MASTER 
							OPEN CUR_DESIG
							FETCH NEXT FROM CUR_DESIG INTO @DESIG_NAME
							while @@Fetch_Status = 0
								BEGIN
									EXEC P0040_DESIGNATION_MASTER 0 ,@CMP_ID,@DESIG_NAME,0,0,'I'
									FETCH NEXT FROM CUR_DESIG INTO @DESIG_NAME
								END
							CLOSE CUR_DESIG
							DEALLOCATE CUR_DESIG
					END
				else if @FORM ='GRADE'
					BEGIN
						DECLARE CUR_GRADE CURSOR FOR 
							select DISTINCT GRADE_NAME
							--from [payroll].dbo.DESIGNATION_MASTER 
							from [payroll_TDS].dbo.GRADE_MASTER
							OPEN CUR_GRADE
							FETCH NEXT FROM CUR_GRADE INTO @DESIG_NAME
							while @@Fetch_Status = 0
								BEGIN
									EXEC P0040_GRADE_MASTER  0 ,@CMP_ID,0,@DESIG_NAME,@DESIG_NAME,0,'I'
									FETCH NEXT FROM CUR_GRADE INTO @DESIG_NAME
								END
							CLOSE CUR_GRADE
							DEALLOCATE CUR_GRADE
					END		
				else if @FORM ='TYPE'
					BEGIN
						DECLARE CUR_TYPE CURSOR FOR 
							select DISTINCT TYPE_NAME
							from [payroll_TDS].dbo.EMP_TYPE_MASTER
							OPEN CUR_TYPE
							FETCH NEXT FROM CUR_TYPE INTO @DESIG_NAME
							while @@Fetch_Status = 0
								BEGIN
									EXEC P0040_TYPE_MASTER  0 ,@CMP_ID,@DESIG_NAME,0,0,'I'
									FETCH NEXT FROM CUR_TYPE INTO @DESIG_NAME
								END
							CLOSE CUR_TYPE
							DEALLOCATE CUR_TYPE
					END								
					
		END
	ELSE IF @DATABASE ='PAYROLL'
		BEGIN
			IF @FORM = 'EMP MASTER'	
					BEGIN
							DECLARE CUR_EMP CURSOR FOR 
							select emp_name,Grade_Name,Join_Date,Basic_rate,DEPT_NAME,DESIG_NAME,TYPE_NAME 
									,GENDER,MARTIAL_sTATUS
							from [payroll].dbo.get_Emp_master order by code						
							--from [payroll].dbo.get_Emp_master where is_left is null	order by code
							OPEN CUR_EMP
							FETCH NEXT FROM CUR_EMP INTO @EMP_NAME,@GRADE_NAME,@Date_Of_Join,@Basic_Salary,@DEPT_NAME,@DESIG_NAME,@TYPE_NAME,@GENDER,@MARITAL_STATUS
							while @@Fetch_Status = 0
								BEGIN
									SELECT @EMP_CODE = ISNULL(MAX(EMP_CODE),0)+ 1 FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE CMP_ID = @CMP_ID
									IF @GENDER ='M' 
										SET @INITIAL ='Mr.'
									else if @gender ='F' and @Marital_Status ='M'
										set @Initial ='Mrs.'
									else if @gender ='F' and @Marital_Status ='U'
										set @Initial ='Miss.'
									
									set @Emp_First_Name = substring(@Emp_Name,1,charindex(' ',@Emp_Name,1)) 
									set @Emp_Second_NAme = ''
									if charindex(' ',@Emp_Name,1) >0
										set @Emp_last_Name = substring(@Emp_Name,charindex(' ',@Emp_Name,1) +1,len(@Emp_Name))
									else
										set @Emp_last_Name = ''
									
									set @Emp_ID = 0
									set @Increment_Id = 0
									select @Grd_ID =grd_ID from T0040_Grade_MAster WITH (NOLOCK) where cmp_ID = @Cmp_ID and Grd_Name =@Grade_Name
									select @Dept_ID =Dept_ID from T0040_Department_Master WITH (NOLOCK) where cmp_ID = @Cmp_ID and Dept_Name =@Dept_Name
									select @Desig_ID =Desig_ID from T0040_Designation_Master WITH (NOLOCK) where cmp_ID = @Cmp_ID and Desig_Name =@Desig_Name
									select @Type_ID =Type_Id from T0040_Type_Master WITH (NOLOCK) where cmp_ID = @Cmp_ID and Type_Name =@Type_Name
									
									select @Shift_ID = min(Shift_ID) From T0040_Shift_Master WITH (NOLOCK) where cmp_ID =@Cmp_ID
									if @Emp_First_Name <> '' and @Emp_Last_Name <> ''
										begin
												EXEC P0080_EMP_MASTER @Emp_ID 	output 
												,@Cmp_ID		  ,@Branch_ID		 ,NULL   ,@Grd_ID		
												,@Dept_ID		,@Desig_Id			,@Type_ID			,@Shift_ID		
												,NULL   ,@Increment_ID output  ,@Emp_code		  ,@Initial		  ,@Emp_First_Name 	  ,@Emp_Second_Name 
												   ,@Emp_Last_Name	  ,@Curr_ID		  ,@Date_Of_Join	  ,''		  ,''  ,''  ,''  ,@Date_Of_Birth    ,@Marital_Status 
												   ,@Gender		  ,NULL  ,'INDIAN'  ,@Loc_ID		  ,@Street_1		  ,@City		  ,@State		  ,@Zip_code		
												   ,@Home_Tel_no	  ,@Mobile_No		  ,@Work_Tel_No	  ,@Work_Email		  ,@Other_Email	  ,@Present_Street 
												   ,@Present_City     ,@Present_State    ,@Present_Post_Box   ,0  ,@Basic_Salary	  ,''  ,'Monthly'
												   ,'Day'   ,'Transfer'   ,'Ac No '    ,0		   ,'00:00'   ,'00:00'   ,0   ,1   ,1   ,0   ,'I'
												   
												
												
												Declare Cur_Ad cursor for
												select AD_ID,AD_Flag,AD_Mode,AD_Percentage,AD_max_Limit,AD_aMOUNT From T0050_AD_Master WITH (NOLOCK) where Cmp_ID = @Cmp_ID 
												open cur_ad
												Fetch next from cur_AD into @AD_ID,@AD_Flag ,@AD_Mode,@AD_Percentage,@AD_max_Limit,@AD_AMOUNT
												while @@fetch_Status = 0
													begin
														exec dbo.P0100_EMP_EARN_DEDUCTION 0,@Emp_ID,@Cmp_ID,@AD_ID,@Increment_ID,@Date_OF_Join,@AD_Flag,@AD_Mode,@AD_Percentage,@AD_Amount,@AD_Max_Limit,'I'	
														Fetch next from cur_AD into @AD_ID,@AD_Flag ,@AD_Mode,@AD_Percentage,@AD_max_Limit,@AD_AMOUNT
													end
												close cur_Ad
												deallocate cur_Ad
												   
										end   
								
									FETCH NEXT FROM CUR_EMP INTO @EMP_NAME,@GRADE_NAME,@Date_Of_Join,@Basic_Salary,@DEPT_NAME,@DESIG_NAME,@TYPE_NAME,@GENDER,@MARITAL_STATUS
								END
							CLOSE CUR_EMP
							DEALLOCATE CUR_EMP	
					END
				else if @Form ='PT'
					begin
						exec P0040_PROFESSIONAL_SETTING @Cmp_Id,@Branch_ID,0,'01-jan-2008',1,'3000','5999',20,'I'
						exec P0040_PROFESSIONAL_SETTING @Cmp_Id,@Branch_ID,0,'01-jan-2008',1,'6000','8999',80,'I'
						exec P0040_PROFESSIONAL_SETTING @Cmp_Id,@Branch_ID,0,'01-jan-2008',1,'9000','12999',150,'I'
						exec P0040_PROFESSIONAL_SETTING @Cmp_Id,@Branch_ID,0,'01-jan-2008',1,'12000','0',200,'I'
					end	
				else if @FORM ='DEPARTMENT'
					BEGIN
						DECLARE CUR_DEPT CURSOR FOR 
							select DISTINCT DEPT_NAME 
							from [payroll].dbo.DEPARTMENT_MASTER 
							OPEN CUR_DEPT
							FETCH NEXT FROM CUR_DEPT INTO @DEPT_NAME
							while @@Fetch_Status = 0
								BEGIN
									EXEC P0040_DEPARTMENT_MASTER 0 ,@CMP_ID,@DEPT_NAME,0,'I'
									FETCH NEXT FROM CUR_DEPT INTO @DEPT_NAME
								END
							CLOSE CUR_DEPT
							DEALLOCATE CUR_DEPT
									
						
					END
				else if @FORM ='DESIGNATION'
					BEGIN
						DECLARE CUR_DESIG CURSOR FOR 
							select DISTINCT DESIG_NAME
							from [payroll].dbo.DESIGNATION_MASTER 
							OPEN CUR_DESIG
							FETCH NEXT FROM CUR_DESIG INTO @DESIG_NAME
							while @@Fetch_Status = 0
								BEGIN
									EXEC P0040_DESIGNATION_MASTER 0 ,@CMP_ID,@DESIG_NAME,0,0,'I'
									FETCH NEXT FROM CUR_DESIG INTO @DESIG_NAME
								END
							CLOSE CUR_DESIG
							DEALLOCATE CUR_DESIG
					END			
				else if @FORM ='GRADE'
					BEGIN
						DECLARE CUR_GRADE CURSOR FOR 
							select DISTINCT GRADE_NAME
							from [payroll].dbo.GRADE_MASTER
							OPEN CUR_GRADE
							FETCH NEXT FROM CUR_GRADE INTO @DESIG_NAME
							while @@Fetch_Status = 0
								BEGIN
									EXEC P0040_GRADE_MASTER  0 ,@CMP_ID,0,@DESIG_NAME,@DESIG_NAME,0,'I'
									FETCH NEXT FROM CUR_GRADE INTO @DESIG_NAME
								END
							CLOSE CUR_GRADE
							DEALLOCATE CUR_GRADE
					END		
				else if @FORM ='TYPE'
					BEGIN
						DECLARE CUR_TYPE CURSOR FOR 
							select DISTINCT TYPE_NAME
							from [payroll].dbo.EMP_TYPE_MASTER
							OPEN CUR_TYPE
							FETCH NEXT FROM CUR_TYPE INTO @DESIG_NAME
							while @@Fetch_Status = 0
								BEGIN
									EXEC P0040_TYPE_MASTER  0 ,@CMP_ID,@DESIG_NAME,0,0,'I'
									FETCH NEXT FROM CUR_TYPE INTO @DESIG_NAME
								END
							CLOSE CUR_TYPE
							DEALLOCATE CUR_TYPE
					END							
										
		END
				
ELSE IF @DATABASE ='PAYROLL_BALAJI'
		BEGIN
			IF @FORM = 'EMP MASTER'	
					BEGIN
							DECLARE CUR_EMP CURSOR FOR 
							select emp_name,Grade_Name,Join_Date,Basic_rate,DEPT_NAME,DESIG_NAME,TYPE_NAME 
									,GENDER,MARTIAL_sTATUS
							from [payroll_BALAJI].dbo.get_Emp_master order by code						
							--from [payroll].dbo.get_Emp_master where is_left is null	order by code
							OPEN CUR_EMP
							FETCH NEXT FROM CUR_EMP INTO @EMP_NAME,@GRADE_NAME,@Date_Of_Join,@Basic_Salary,@DEPT_NAME,@DESIG_NAME,@TYPE_NAME,@GENDER,@MARITAL_STATUS
							while @@Fetch_Status = 0
								BEGIN
									SELECT @EMP_CODE = ISNULL(MAX(EMP_CODE),0)+ 1 FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE CMP_ID = @CMP_ID
									IF @GENDER ='M' 
										SET @INITIAL ='Mr.'
									else if @gender ='F' and @Marital_Status ='M'
										set @Initial ='Mrs.'
									else if @gender ='F' and @Marital_Status ='U'
										set @Initial ='Miss.'
									
									set @Emp_First_Name = substring(@Emp_Name,1,charindex(' ',@Emp_Name,1)) 
									set @Emp_Second_NAme = ''
									if charindex(' ',@Emp_Name,1) >0
										set @Emp_last_Name = substring(@Emp_Name,charindex(' ',@Emp_Name,1) +1,len(@Emp_Name))
									else
										set @Emp_last_Name = ''
									
									set @Emp_ID = 0
									set @Increment_Id = 0
									select @Grd_ID =grd_ID from T0040_Grade_MAster WITH (NOLOCK) where cmp_ID = @Cmp_ID and Grd_Name =@Grade_Name
									select @Dept_ID =Dept_ID from T0040_Department_Master WITH (NOLOCK) where cmp_ID = @Cmp_ID and Dept_Name =@Dept_Name
									select @Desig_ID =Desig_ID from T0040_Designation_Master WITH (NOLOCK) where cmp_ID = @Cmp_ID and Desig_Name =@Desig_Name
									select @Type_ID =Type_Id from T0040_Type_Master WITH (NOLOCK) where cmp_ID = @Cmp_ID and Type_Name =@Type_Name
									
									select @Shift_ID = min(Shift_ID) From T0040_Shift_Master WITH (NOLOCK) where cmp_ID =@Cmp_ID
									if @Emp_First_Name <> '' and @Emp_Last_Name <> ''
										begin
												EXEC P0080_EMP_MASTER @Emp_ID 	output 
												,@Cmp_ID		  ,@Branch_ID		 ,NULL   ,@Grd_ID		
												,@Dept_ID		,@Desig_Id			,@Type_ID			,@Shift_ID		
												,NULL   ,@Increment_ID output  ,@Emp_code		  ,@Initial		  ,@Emp_First_Name 	  ,@Emp_Second_Name 
												   ,@Emp_Last_Name	  ,@Curr_ID		  ,@Date_Of_Join	  ,''		  ,''  ,''  ,''  ,@Date_Of_Birth    ,@Marital_Status 
												   ,@Gender		  ,NULL  ,'INDIAN'  ,@Loc_ID		  ,@Street_1		  ,@City		  ,@State		  ,@Zip_code		
												   ,@Home_Tel_no	  ,@Mobile_No		  ,@Work_Tel_No	  ,@Work_Email		  ,@Other_Email	  ,@Present_Street 
												   ,@Present_City     ,@Present_State    ,@Present_Post_Box   ,0  ,@Basic_Salary	  ,''  ,'Monthly'
												   ,'Day'   ,'Transfer'   ,'Ac No '    ,0		   ,'00:00'   ,'00:00'   ,0   ,1   ,1   ,0   ,'I'
												   
												
												
												Declare Cur_Ad cursor for
												select AD_ID,AD_Flag,AD_Mode,AD_Percentage,AD_max_Limit,AD_aMOUNT From T0050_AD_Master WITH (NOLOCK) where Cmp_ID = @Cmp_ID 
												open cur_ad
												Fetch next from cur_AD into @AD_ID,@AD_Flag ,@AD_Mode,@AD_Percentage,@AD_max_Limit,@AD_AMOUNT
												while @@fetch_Status = 0
													begin
														exec dbo.P0100_EMP_EARN_DEDUCTION 0,@Emp_ID,@Cmp_ID,@AD_ID,@Increment_ID,@Date_OF_Join,@AD_Flag,@AD_Mode,@AD_Percentage,@AD_Amount,@AD_Max_Limit,'I'	
														Fetch next from cur_AD into @AD_ID,@AD_Flag ,@AD_Mode,@AD_Percentage,@AD_max_Limit,@AD_AMOUNT
													end
												close cur_Ad
												deallocate cur_Ad
												   
										end   
								
									FETCH NEXT FROM CUR_EMP INTO @EMP_NAME,@GRADE_NAME,@Date_Of_Join,@Basic_Salary,@DEPT_NAME,@DESIG_NAME,@TYPE_NAME,@GENDER,@MARITAL_STATUS
								END
							CLOSE CUR_EMP
							DEALLOCATE CUR_EMP	
					END
				else if @FORM ='DEPARTMENT'
					BEGIN
						DECLARE CUR_DEPT CURSOR FOR 
							select DISTINCT DEPT_NAME 
							from [payroll_BALAJI].dbo.DEPARTMENT_MASTER 
							OPEN CUR_DEPT
							FETCH NEXT FROM CUR_DEPT INTO @DEPT_NAME
							while @@Fetch_Status = 0
								BEGIN
									EXEC P0040_DEPARTMENT_MASTER 0 ,@CMP_ID,@DEPT_NAME,0,'I'
									FETCH NEXT FROM CUR_DEPT INTO @DEPT_NAME
								END
							CLOSE CUR_DEPT
							DEALLOCATE CUR_DEPT
									
						
					END
				else if @FORM ='DESIGNATION'
					BEGIN
						DECLARE CUR_DESIG CURSOR FOR 
							select DISTINCT DESIG_NAME
							from [payroll_BALAJI].dbo.DESIGNATION_MASTER 
							OPEN CUR_DESIG
							FETCH NEXT FROM CUR_DESIG INTO @DESIG_NAME
							while @@Fetch_Status = 0
								BEGIN
									EXEC P0040_DESIGNATION_MASTER 0 ,@CMP_ID,@DESIG_NAME,0,0,'I'
									FETCH NEXT FROM CUR_DESIG INTO @DESIG_NAME
								END
							CLOSE CUR_DESIG
							DEALLOCATE CUR_DESIG
					END			
				else if @FORM ='GRADE'
					BEGIN
						DECLARE CUR_GRADE CURSOR FOR 
							select DISTINCT GRADE_NAME
							from [payroll_BALAJI].dbo.GRADE_MASTER
							OPEN CUR_GRADE
							FETCH NEXT FROM CUR_GRADE INTO @DESIG_NAME
							while @@Fetch_Status = 0
								BEGIN
									EXEC P0040_GRADE_MASTER  0 ,@CMP_ID,0,@DESIG_NAME,@DESIG_NAME,0,'I'
									FETCH NEXT FROM CUR_GRADE INTO @DESIG_NAME
								END
							CLOSE CUR_GRADE
							DEALLOCATE CUR_GRADE
					END		
				else if @FORM ='TYPE'
					BEGIN
						DECLARE CUR_TYPE CURSOR FOR 
							select DISTINCT TYPE_NAME
							from [payroll_BALAJI].dbo.EMP_TYPE_MASTER
							OPEN CUR_TYPE
							FETCH NEXT FROM CUR_TYPE INTO @DESIG_NAME
							while @@Fetch_Status = 0
								BEGIN
									EXEC P0040_TYPE_MASTER  0 ,@CMP_ID,@DESIG_NAME,0,0,'I'
									FETCH NEXT FROM CUR_TYPE INTO @DESIG_NAME
								END
							CLOSE CUR_TYPE
							DEALLOCATE CUR_TYPE
					END							
										
		END
	else if @DAtabase ='ALLOWANCE'
		BEGIN
				Declare @Emp_Ad Table
				 (
					Emp_ID		numeric ,
					Cmp_ID		numeric,
					AD_ID		numeric,
					Increment_Id 	numeric ,
					For_Date	Datetime
				 )

				insert into @emp_ad (emp_ID,Cmp_Id,AD_ID,Increment_ID,For_Date)
				select Emp_ID,e.cmp_ID ,AD_Id,Increment_Id,Date_of_Join from T0080_emp_master e WITH (NOLOCK) Cross Join 
				T0050_AD_Master am WITH (NOLOCK)
				where E.cmp_ID = @Cmp_ID and am.cmp_id =@Cmp_ID

				
				
					Declare Cur_AD cursor for 
						select emp_ID,ea.cmp_ID,ea.AD_Id,Increment_Id,For_Date ,AD_FLAG,AD_MODE,AD_PERCENTAGE from @emp_AD ea inner join 
						T0050_AD_master ad WITH (NOLOCK) on ea.ad_ID = ad.ad_ID 
						
					open cur_AD
					fetch next from Cur_AD into @Emp_Id,@cmp_Id,@AD_Id,@Increment_ID,@Date_of_join,@AD_FLAG,@AD_MODE,@AD_PERCENTAGE
					while @@fetch_status = 0
						begin
							exec P0100_EMP_EARN_DEDUCTION 0 ,@EMP_ID,@CMP_ID,@AD_ID,@INCREMENT_ID,@Date_of_join,@AD_FLAG,@AD_MODE,@AD_PERCENTAGE,0,0,'I'
							fetch next from Cur_AD into @Emp_Id,@cmp_Id,@AD_Id,@Increment_ID,@Date_of_join,@AD_FLAG,@AD_MODE,@AD_PERCENTAGE
						end
					close cur_ad
					deallocate cur_ad 
				END
 
	
	
	RETURN




