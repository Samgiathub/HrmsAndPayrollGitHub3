
---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0080_EMP_MASTER_IMPORT]  
	@Cmp_ID				NUMERIC(18,0)  
   ,@Emp_code			NUMERIC(18,0)  
   ,@Initial			VARCHAR(10)   
   ,@Emp_First_Name		VARCHAR(100)  
   ,@Emp_Second_Name	VARCHAR(100)  
   ,@Emp_Last_Name		VARCHAR(100) 
   ,@Branch_Name		VARCHAR(100)     
   ,@Grd_Name			VARCHAR(100)     
   ,@Dept_Name			VARCHAR(100)     
   ,@Product_Name		VARCHAR(100)     
   ,@Desig_Name			VARCHAR(100)     
   ,@Type_Name			VARCHAR(100)     
   ,@Shift_Name			VARCHAR(100)     
   ,@Bank_Name			VARCHAR(100)   
   ,@Curr_Name			VARCHAR(100)     
   ,@Date_Of_Join		DATETIME  
   ,@Pan_No				VARCHAR(30)  
   ,@ESIC_No			VARCHAR(30)  
   ,@PF_No				VARCHAR(30)  
   ,@Date_Of_Birth		DATETIME	= NULL  
   ,@Marital_Status		VARCHAR(20) = '0'  
   ,@Gender				CHAR(1)		= 'M'  
   ,@Nationality		VARCHAR(20)	= 'Indian'  
   ,@Loc_Name			VARCHAR(100)='India'  
   ,@Street_1			VARCHAR(250)  
   ,@City				VARCHAR(30)  
   ,@State				VARCHAR(20)  
   ,@Zip_code			VARCHAR(20)  
   ,@Home_Tel_no		VARCHAR(30)  
   ,@Mobile_No			VARCHAR(30)  
   ,@Work_Tel_No		VARCHAR(30)  
   ,@Work_Email			VARCHAR(50)  
   ,@Other_Email		VARCHAR(50)  
   ,@Present_Street		VARCHAR(250)  
   ,@Present_City		VARCHAR(30)  
   ,@Present_State		VARCHAR(30)  
   ,@Present_Post_Box	VARCHAR(20)  
   ,@Basic_Salary		NUMERIC(18,2)  
   ,@Gross_salary		NUMERIC(18,2)  
   ,@Wages_Type			VARCHAR(10)	= 'Monthly'  
   ,@Salary_Basis_On	VARCHAR(20)	= 'Day'  
   ,@Payment_Mode		VARCHAR(20) = 'Bank Transfer'  
   ,@Inc_Bank_AC_No		VARCHAR(20)  
   ,@Emp_OT				NUMERIC(1)	= 0  
   ,@Emp_OT_Min_Limit	VARCHAR(10) = '00:00'  
   ,@Emp_OT_Max_Limit	VARCHAR(10) = '00:00'  
   ,@Emp_Late_mark		NUMERIC(18) = 0  
   ,@Emp_Full_PF		NUMERIC(18) = 1  
   ,@Emp_PT				NUMERIC(18) = 1  
   ,@Emp_Fix_Salary		NUMERIC(18) = 0  
   ,@Blood_Group		VARCHAR(10)  
   ,@Enroll_No			NUMERIC (18,0)  
   ,@Father_Name		VARCHAR(100) = ''  
   ,@Emp_IFSC_No		VARCHAR(100) = ''  
   ,@Adult_NO			NUMERIC(18,0) = 0  
   ,@Confirm_Date		DATETIME  
   ,@Probation			NUMERIC(18,0) = 0  
   ,@Superior			NUMERIC(18,0) = NULL --chnaged by Falak on 29-APR-2011  
   ,@Old_Ref_No			VARCHAR(50)	= NULL  
   ,@Row_No				NUMERIC(18,0) = 0 -- which Define row number Of excel Sheet Which Use Fro Log system Of Employee Import.So We Anylyze That In Which Rows Errors Are there.  
   ,@Log_Status			INT = 0 OUTPUT --Put By Nikunj 25-March-2011  
   ,@Alpha_Code			VARCHAR(10) = ''   --ADDED BY Falak on 25-MAY-2011  
   ,@Emp_Superior		VARCHAR(20) = ''  
   --,@Emp_Superior numeric(18,0) = 0   -- Added by Alpesh 08-06-2011  
   ,@Is_LWF INT=0  
   ,@WeekDay_OT_Rate	NUMERIC(18,2) = 0  
   ,@Weekoff_OT_Rate	NUMERIC(18,2) = 0  
   ,@Holiday_OT_Rate	NUMERIC(18,2) = 0  
   ,@Business_Segment	VARCHAR(50) = NULL	-- Added by Gadriwala Muslim 03082013
   ,@Vertical			VARCHAR(50) = NULL	-- Added by Gadriwala Muslim 03082013
   ,@sub_Vertical		VARCHAR(50) = NULL	-- Added by Gadriwala Muslim 03082013
   ,@sub_Branch			VARCHAR(50) = NULL	-- Added by Gadriwala Muslim 03082013
   ,@Group_of_Joining	DATETIME	= NULL	-- Added by Gadriwala Muslim 03082013
   ,@Salary_Cycle		VARCHAR(50) = NULL	-- Added By Hiral 13 August, 2013
   ,@Cmp_Full_PF		NUMERIC(18) = 1   -- Added by rohit on 06092013
AS  
 
	SET NOCOUNT ON 
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ARITHABORT ON
	set DEADLOCK_PRIORITY LOW;
		
	IF @Marital_Status = ''  
		SET @Marital_Status = '0'  
    
	IF @Gender = ''  
		SET @Gender = 'M'  
    
    -- Added By Ali 26122013 -- Start
	If @Initial = 'Ms.' Or @Initial = 'Ms' Or @Initial = 'Mrs.' Or @Initial = 'Mrs'
	BEGIN
		Set @Gender = 'F'
	END
	ELSE
	BEGIN
		Set @Gender = 'M'
	END
	-- Added By Ali 26122013 -- Start
	
	IF @Nationality = ''  
		SET @Nationality = 'Indian'  
     
	IF @Loc_Name = ''  
		SET @Loc_Name = 'India'  
       
	IF @Wages_Type = ''    
		SET @Wages_Type = 'Monthly'  
    
	IF @Salary_Basis_On = ''  
		SET @Salary_Basis_On = 'Day'  
    
	IF @Payment_Mode = ''  
		SET @Payment_Mode = 'Bank Transfer'  
    
	IF @Emp_OT_Min_Limit = ''  
		SET @Emp_OT_Min_Limit = '00:00'  
    
	IF @Emp_OT_Max_Limit = ''  
		SET @Emp_OT_Max_Limit = '00:00'  
    
	IF @Emp_Full_PF IS NULL  
		SET @Emp_Full_PF = 1  
    
     IF @Cmp_Full_PF IS NULL  -- Rohit on 06092013  
		SET @Cmp_Full_PF = 1  
    
	IF @Emp_PT IS NULL  
		SET @Emp_PT = 1  
   
	IF @Alpha_Code=''  
		SET @Alpha_Code = NULL   
    
	IF @Emp_Superior = ''  
		SET @Emp_Superior = '0'
	
	-- Added By Hiral 14 August, 2013 (Start)
	IF @Salary_Cycle = ''  
		SET @Salary_Cycle = '0'  
	-- Added By Hiral 14 August, 2013 (End)
	
    --Added By Gadriwala Muslim 23012014
    if @Emp_Last_Name is Null or @Emp_Last_Name = ''
		set @Emp_Last_Name = ' '
	
	if @Group_of_Joining = ''
		set @Group_of_Joining = @Date_Of_Join  -- Added By Gadriwala 03042014
		
	DECLARE @Emp_ID			As NUMERIC(18,0)   
	DECLARE @Branch_ID		As NUMERIC(18,0)--done  
	DECLARE @Cat_ID			As NUMERIC(18,0)  
	DECLARE @Grd_ID			As NUMERIC(18,0)--Done  
	DECLARE @Dept_ID		As NUMERIC(18,0)--Done  
	DECLARE @Desig_Id		As NUMERIC(18,0)--Done  
	DECLARE @Type_ID		As NUMERIC(18,0)--Done  
	DECLARE @Shift_ID		As NUMERIC(18,0)--Done  
	DECLARE @Bank_ID		As NUMERIC(18,0)--Done  
	DECLARE @Curr_ID		As NUMERIC(18,0)-- done  
	DECLARE @Increment_ID	As NUMERIC(18,0)   
	DECLARE @Loc_ID			As NUMERIC(18,0)  
	DECLARE @State_ID		As NUMERIC(18,0)  
	DECLARE @Login_ID		As NUMERIC(18,0)   
	SET @Login_ID = 0  
	DECLARE @Chg_Pwd		As INT -- Added By Alpesh on 25-05-2011 for first time login change password dialogbox for employee   
	SET @Chg_Pwd = 0  
	DECLARE @emp_Id_sup		AS NUMERIC(18,0)  
	SET @emp_Id_sup = 0  
	DECLARE @Segment_ID		As NUMERIC(18,0) -- Added by Gadriwala 03082013
	DECLARE @Vertical_ID	As NUMERIC(18,0) -- Added by Gadriwala 03082013
	DECLARE @SubVertical_ID As NUMERIC(18,0) -- Added by Gadriwala 03082013 
	DECLARE @SubBranch_ID	As NUMERIC(18,0) -- Added by Gadriwala 03082013 
	
	Declare @Salary_Cycle_ID As Numeric(18,0)	-- Added By Hiral 14 August, 2013
	Set @Salary_Cycle_ID = 0						-- Added By Hiral 14 August, 2013
	
	IF @Emp_Superior <> '0'  
		BEGIN 
			IF NOT EXISTS(SELECT Emp_Id FROM dbo.T0080_Emp_Master WITH (NOLOCK) WHERE Alpha_Emp_Code=@Emp_Superior AND Cmp_Id=@Cmp_ID)  
				BEGIN      
					INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,'Superior Code Not Exits',@Emp_Superior,'Please First ALTER Employee To Assign',GETDATE(),'Employee Master','')  
					SET @Log_Status=1
					RETURN  
				END  
			ELSE  
				BEGIN  
					SELECT @emp_Id_sup = Emp_Id FROM dbo.T0080_Emp_Master WITH (NOLOCK) WHERE Cmp_Id=@cmp_Id AND Alpha_Emp_Code=@Emp_Superior  
				END     
		END   
    
	IF EXISTS(SELECT LOC_ID FROM T0001_LOCATION_MASTER WITH (NOLOCK) WHERE LOC_Name =@LOC_Name)  
		BEGIN    
			SELECT @Loc_ID = LOC_ID FROM T0001_LOCATION_MASTER WITH (NOLOCK) WHERE LOC_Name =@LOC_Name   
		END  
	ELSE  
		BEGIN       
			IF @Loc_Name <> ''  
				BEGIN   
					EXEC P0001_LOCATION_MASTER @Loc_ID OUTPUT ,@Loc_Name  
				END  
			ELSE  
				BEGIN  
					INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,'Location Name is Not Proper',@Loc_Name,'Please Enter Location Name',GETDATE(),'Employee Master','')  
				END   
		END   
  
	IF EXISTS(SELECT Branch_ID FROM T0030_Branch_Master WITH (NOLOCK) WHERE Branch_Name =@Branch_Name AND Cmp_ID=@Cmp_ID)  
		BEGIN  
			SELECT @Branch_ID = Branch_ID,@State_id=State_ID FROM dbo.T0030_Branch_Master WITH (NOLOCK) WHERE Branch_Name =@Branch_Name AND Cmp_ID=@Cmp_ID  
		END  
	ELSE  
		BEGIN  
			IF @Branch_Name <> ''  
				BEGIN  
					DECLARE @Branch_Code VARCHAR(10)  
					SET @Branch_Code = LEFT(@Branch_Name,3)  
					EXEC P0030_BRANCH_MASTER @Branch_ID OUTPUT ,@Cmp_ID,@State_ID,@Branch_Code,@Branch_Name,'','','','I'  
				END  
			ELSE  
				BEGIN  
					INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,'Branch Name is Not Proper',@Branch_Name,'Please Enter Branch Name',GETDATE(),'Employee Master','')  
				END    
		END 
		
	IF EXISTS(SELECT Grd_ID FROM T0040_GRADE_Master WITH (NOLOCK) WHERE Grd_Name =@Grd_Name AND Cmp_ID=@Cmp_ID)  
		BEGIN  
			SELECT @Grd_ID = Grd_ID FROM T0040_GRADE_Master WITH (NOLOCK) WHERE Grd_Name =@Grd_Name AND Cmp_ID=@Cmp_ID  
		END  
	ELSE  
		BEGIN    
			IF @Grd_Name <> ''  
				BEGIN  
					EXEC p0040_GRADE_MASTER @Grd_ID OUTPUT ,@Cmp_ID,0,@Grd_Name,@Grd_Name,0,'I',0,0,0,''  
				END  
			ELSE  
				BEGIN  
					INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,'Grade Name is Not Proper',@Grd_Name,'Please Enter Grade Name',GETDATE(),'Employee Master','')  
				END    
		END   
     
	IF EXISTS(SELECT Dept_ID FROM T0040_Department_Master WITH (NOLOCK) WHERE Dept_Name =@Dept_Name AND Cmp_ID=@Cmp_ID)  
		BEGIN  
			SELECT @Dept_ID = Dept_ID FROM T0040_Department_Master WITH (NOLOCK) WHERE Dept_Name =@Dept_Name AND Cmp_ID=@Cmp_ID  
		END  
	ELSE  
		BEGIN        
			IF @Dept_Name <> ''  
				BEGIN   
					EXEC P0040_DEPARTMENT_MASTER @Dept_ID OUTPUT ,@Cmp_ID,@Dept_Name,0,'','I'  
				END   
			ELSE  
				BEGIN  
					SET @Dept_ID = NULL  
				END  
		END   
	
	IF EXISTS(SELECT Desig_ID FROM T0040_Designation_Master WITH (NOLOCK) WHERE Desig_Name =@desig_Name AND Cmp_ID=@Cmp_ID)  
		BEGIN  
			SELECT @Desig_ID = Desig_ID FROM T0040_Designation_Master WITH (NOLOCK) WHERE Desig_Name =@desig_Name AND Cmp_ID=@Cmp_ID  
		END  
	ELSE  
		BEGIN  
			IF @Desig_Name <> ''  
				BEGIN  
					EXEC P0040_DESIGNATION_MASTER @Desig_ID OUTPUT ,@Cmp_ID,@Desig_Name,0,0,0,0,'I'  
				END  
			ELSE  
				BEGIN  
					INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,'Designation Name is Not Proper',@Desig_Name,'Please Enter Designation Name',GETDATE(),'Employee Master','')  
				END    
		END   
  
	IF EXISTS(SELECT TYPE_ID FROM T0040_TYPE_Master WITH (NOLOCK) WHERE TYPE_NAME =@Type_Name AND Cmp_ID=@Cmp_ID)  
		BEGIN  
			SELECT @Type_ID = TYPE_ID FROM T0040_TYPE_Master WITH (NOLOCK) WHERE TYPE_NAME =@Type_Name AND Cmp_ID=@Cmp_ID  
		END  
	ELSE  
		BEGIN  
			IF @Type_Name <> ''  
				BEGIN  
					EXEC P0040_TYPE_MASTER @Type_ID OUTPUT ,@Cmp_ID,@Type_Name,0,0,'I'  
				END  
			ELSE  
				BEGIN  
					INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,'Type Name is Not Proper',@Type_Name,'Please Enter Type Name',GETDATE(),'Employee Master','')  
				END    
		END   
  
	IF EXISTS(SELECT Shift_ID FROM T0040_SHIFT_MASTER WITH (NOLOCK) WHERE Shift_Name =@Shift_Name  AND Cmp_ID=@Cmp_ID)  
		BEGIN  
			SELECT @Shift_ID = Shift_ID FROM T0040_SHIFT_MASTER WITH (NOLOCK) WHERE Shift_Name =@Shift_Name  AND Cmp_ID=@Cmp_ID  
		END  
	ELSE  
		BEGIN  
			IF @Shift_Name <> ''  
				BEGIN  
					EXEC P0040_Shift_Master @Shift_ID OUTPUT ,@Cmp_ID,@Shift_Name,'09:00','17:00','08:00','09:00','17:00','08:00','','','','','','','I'  
				END  
			ELSE  
				BEGIN  
					INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,'Shift Name is Not Proper',@Shift_Name,'Please Enter Shift Name',GETDATE(),'Employee Master','')  
				END     
		END   
  
	IF EXISTS(SELECT Bank_ID FROM T0040_Bank_Master WITH (NOLOCK) WHERE Bank_Name =@Bank_Name AND Cmp_ID=@Cmp_ID)  
		BEGIN  
			SELECT @Bank_ID = Bank_ID FROM T0040_Bank_Master WITH (NOLOCK) WHERE Bank_Name =@Bank_Name AND Cmp_ID=@Cmp_ID  
		END  
	ELSE  
		BEGIN  
			IF @Bank_Name <> ''  
				BEGIN  
					DECLARE @Bank_Code VARCHAR(10)  
					SET @Bank_Code = LEFT(@Bank_Name,2)  
					EXEC P0040_BANK_MASTER @Bank_ID OUTPUT ,@Cmp_ID,@Bank_Code,@Bank_NAme,'','','','','N','I',@Emp_IFSC_No  
				END  
			ELSE  
				BEGIN  
					SET @Bank_ID =NULL  
				END  
		END   
  
	IF EXISTS(SELECT Curr_ID FROM T0040_Currency_MAster WITH (NOLOCK) WHERE Curr_Name =@Curr_Name AND Cmp_ID=@Cmp_ID)  
		BEGIN  
			SELECT @Curr_ID = Curr_ID FROM T0040_Currency_MAster WITH (NOLOCK) WHERE Curr_Name =@Curr_Name AND Cmp_ID=@Cmp_ID  
		END  
	ELSE  
		BEGIN  
			IF @Curr_Name <> ''  
				BEGIN  
					EXEC P0040_CURRENCY_MASTER @Curr_ID OUTPUT ,@Cmp_ID,@Curr_Name,0,'N','','','I'  
				END  
			ELSE  
				BEGIN  
					SET @Curr_ID = NULL  
				END    
		END   
  
	IF EXISTS(SELECT Cat_ID FROM T0030_Category_master WITH (NOLOCK) WHERE Cat_Name =@Product_name AND Cmp_ID=@Cmp_ID)  
		BEGIN    
			SELECT @Cat_ID = Cat_ID FROM T0030_Category_master WITH (NOLOCK) WHERE Cat_Name =@Product_name AND Cmp_ID=@Cmp_ID  
		END  
	ELSE  
		BEGIN  
			IF @Product_name <> ''  
				BEGIN  
					EXEC P0030_Category_master @Cat_ID OUTPUT ,@Product_name,@Cmp_ID,'','I'  
				END   
			ELSE  
				BEGIN  
					SET @Cat_ID = NULL  
				END    
		END  
		
	-- Added By Gadriwala 03082013
	IF EXISTS(SELECT Segment_ID FROM T0040_Business_Segment WITH (NOLOCK) WHERE Segment_Name = @Business_Segment AND Cmp_ID = @Cmp_ID )
		BEGIN
			SELECT @Segment_ID = Segment_ID FROM T0040_Business_Segment WITH (NOLOCK) WHERE Segment_Name = @Business_Segment AND Cmp_ID = @Cmp_ID
		END
	ELSE
		BEGIN
			IF @Business_Segment <> ''
				BEGIN
					Declare @Segment_Code As Varchar(50)					-- Added By Hiral 21 August, 2013
					Set @Segment_Code = Substring(@Business_Segment,1,3)	-- Added By Hiral 21 August, 2013
					EXEC P0040_BUSINESS_SEGEMENT @Segment_ID OUTPUT,@cmp_ID,@Segment_Code,@Business_Segment,'','I'
				END
			ELSE
				BEGIN
					SET @Segment_ID = NULL
				END
		END
		
	--Added By Gadriwala 03082013
    IF EXISTS(SELECT Vertical_ID FROM T0040_Vertical_Segment WITH (NOLOCK) WHERE Vertical_Name = @Vertical AND Cmp_ID = @Cmp_ID )
		BEGIN
			SELECT @Vertical_ID = Vertical_ID FROM T0040_Vertical_Segment WITH (NOLOCK) WHERE Vertical_Name = @Vertical AND Cmp_ID = @Cmp_ID
		END
	ELSE
		BEGIN
			IF @Vertical <> ''
				BEGIN
					Declare @Vertical_Code As Varchar(50)					-- Added By Hiral 21 August, 2013
					Set @Vertical_Code = Substring(@Vertical,1,3)			-- Added By Hiral 21 August, 2013
					EXEC P0040_Vertical @Vertical_ID OUTPUT,@cmp_ID, @Vertical_Code, @Vertical, '', 'I'
				END
			ELSE
				BEGIN
					SET @Vertical_ID = NULL
				END
		END
		
	--Added By Gadriwala 03082013
    IF EXISTS(SELECT SubVertical_ID FROM T0050_SubVertical WITH (NOLOCK) WHERE SubVertical_Name = @Sub_Vertical AND Vertical_ID = @Vertical_ID AND Cmp_ID = @Cmp_ID )
		BEGIN
			SELECT @SubVertical_ID = SubVertical_ID FROM T0050_SubVertical WITH (NOLOCK) WHERE SubVertical_Name = @Sub_Vertical AND Vertical_ID = @Vertical_ID AND Cmp_ID = @Cmp_ID
		END
	ELSE
		BEGIN
			IF @Sub_Vertical <> ''
				BEGIN
					Declare @SubVertical_Code As Varchar(50)					-- Added By Hiral 21 August, 2013
					Set @SubVertical_Code = Substring(@sub_Vertical,1,3)			-- Added By Hiral 21 August, 2013
					EXEC P0050_SubVertical @subvertical_ID OUTPUT,@cmp_ID,@Vertical_ID,@SubVertical_Code,@sub_Vertical,'','I'
				END
			ELSE
				BEGIN
					SET @SubVertical_ID = NULL
				END
		END
			
	--Added By Gadriwala 03082013
	IF EXISTS(SELECT SubBranch_ID FROM T0050_SubBranch WITH (NOLOCK) WHERE SubBranch_Name = @Sub_Branch AND Branch_ID = @Branch_ID AND Cmp_ID = @Cmp_ID )
		BEGIN
			SELECT @SubBranch_ID = SubBranch_ID FROM T0050_SubBranch WITH (NOLOCK) WHERE SubBranch_Name = @sub_Branch AND Branch_ID = @Branch_ID AND Cmp_ID = @Cmp_ID
		END
	ELSE
		BEGIN
			IF @sub_Branch <> ''
				BEGIN
					Declare @SubBranch_Code As Varchar(50)					-- Added By Hiral 21 August, 2013
					Set @SubBranch_Code = Substring(@sub_Branch,1,3)		-- Added By Hiral 21 August, 2013
					EXEC P0050_SubBranch @subBranch_ID OUTPUT,@cmp_ID,@Branch_ID,@SubBranch_Code,@sub_Branch,'','I'
				END
			ELSE
				BEGIN
					SET @SubBranch_ID = NULL
				END
		END
		
	-- Added By Hiral 14 August, 2013 (Start)
	IF @Salary_Cycle <> '0'
		BEGIN 
			IF NOT EXISTS(SELECT Tran_ID FROM dbo.T0040_Salary_Cycle_Master WITH (NOLOCK) WHERE Name = @Salary_Cycle AND Cmp_Id = @Cmp_ID)  
				BEGIN      
					INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,'Salary Cycle Not Exits',@Emp_Superior,'Please First Add Salary Cycle In Master',GETDATE(),'Employee Master','')  
					SET @Log_Status=1  
					RETURN  
				END  
			ELSE  
				BEGIN  
					SELECT @Salary_Cycle_ID = Tran_ID FROM dbo.T0040_Salary_Cycle_Master WITH (NOLOCK) WHERE Cmp_Id = @cmp_Id AND Name = @Salary_Cycle  
				END     
		END
	-- Added By Hiral 14 August, 2013 (End)
		
	IF @Cat_ID = 0  
		SET @Cat_ID = NULL  
	
	IF @Dept_ID = 0  
		SET @Dept_ID = NULL   
		
	IF @Desig_Id = 0  
		SET @Desig_Id = NULL 
		 
	IF @Type_ID =0  
		SET @Type_ID = NULL  
 
	IF @Loc_ID =0  
		SET @Loc_ID = NULL  
 
	IF @Curr_ID =0  
		SET @Curr_ID = NULL  
 
	IF @Bank_ID =0  
		SET @Bank_ID = NULL  
 
	IF @Basic_Salary =0   
		SET @Basic_Salary = NULL  
	
	IF @Date_Of_Birth =  ''  
		SET  @Date_Of_Birth = NULL  
 
	IF @Wages_Type = ''  
		SET @Wages_Type= 'Monthly'  
 
	IF @Salary_Basis_On =''  
		SET @Salary_Basis_On ='Day'  
 
	IF @Payment_Mode = ''  
		SET @Payment_Mode= 'Cash'  
	
	IF @Inc_Bank_AC_No = ''  
		SET @Inc_Bank_AC_No = NULL  
 
	IF @Confirm_Date = ''  
		SET @Confirm_Date = NULL
		  
    IF @Segment_ID = 0
		SET @Segment_ID = NULL	-- Added By Gadriwala 03082013
   
	IF @Vertical_ID  = 0
		SET @Vertical_ID = NULL  -- Added By Gadriwala 03082013
 
	IF @SubVertical_ID = 0 
		SET @SubVertical_ID = NULL -- Added By Gadriwala 03082013
  
	IF @SubBranch_ID = 0 
		SET @SubBranch_ID = NULL  -- Added By Gadriwala 03082013
  
	IF @Group_of_Joining = ''
		SET @Group_of_Joining = NULL  -- Added By Gadriwala 03082013
		
	IF @Date_Of_Join = ''   
		BEGIN  
			INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,'Date Of Join is Not Proper',NULL,'Enter Date Of Join Proper It Must be dd-MMM-yyyy',GETDATE(),'Employee Master','')  
			SET @Emp_ID = 0     
		END   
    
	IF @Emp_Code = 0  
		BEGIN        
			INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,'Employee Code is Null Or 0 Or Was Not Properly Inserted',@Emp_Code,'Enter Employee Code Proper',GETDATE(),'Employee Master','')     
		END  
    
	IF @Emp_First_Name = '' --Added By Mihir Trivedi on 14/08/2012  
		BEGIN  
			INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,'Employee First Name is Null Was Not Properly Inserted',@Emp_Code,'Enter Proper Employee First Name',GETDATE(),'Employee Master','')     
			SET @Log_Status=1   
			RETURN  
		END   
    
     --Commented  By Gadriwala Muslim 23012014
     
	--IF @Emp_Last_Name = '' --Added By Mihir Trivedi on 14/08/2012  
	--	BEGIN  
	--		INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,'Employee Last Name is Null Was Not Properly Inserted',@Emp_Code,'Enter Proper Employee Last Name',GETDATE(),'Employee Master')     
	--		SET @Log_Status=1   
	--		RETURN  
	--	END  
    
	IF @Emp_Code=0 OR @Date_Of_Join='' OR @Shift_Name='' OR @Type_Name='' OR @Desig_Name='' OR @Grd_Name='' OR @LOC_Name='' OR @Branch_Name='' OR @Emp_ID=0  
		BEGIN    
			SET @Log_Status=1     
			Return--Nikunj 25-03-2011  
			--Here I Check All Mandatory Fields.In Above in every Condition we don't return becuase here in one time we get all erros.     
		END   
    
	IF @Increment_ID= 0   
		SET @Increment_ID= NULL    
  
	DECLARE @Emp_Full_Name  VARCHAR(250)  
	DECLARE @loginname   VARCHAR(50)  
	DECLARE @Domain_Name  VARCHAR(50)  
	DECLARE @old_Join_Date  DATETIME   
	DECLARE @Default_Weekof  VARCHAR(50)   
   
	DECLARE @Cmp_Code AS VARCHAR(5)  
	DECLARE @Branch_Code_1 AS VARCHAR(10)  
	DECLARE @Alpha_Emp_Code AS VARCHAR(50)  
	DECLARE @Is_Auto_Alpha_Numeric_Code TINYINT  
	DECLARE @No_Of_Digits NUMERIC   --Added by Mihir 22122011  
   
	SELECT @Domain_Name = Domain_Name,@Cmp_Code = Cmp_Code,@Is_Auto_Alpha_Numeric_Code = Is_Auto_Alpha_Numeric_Code,@No_Of_Digits = No_Of_Digit_Emp_Code  FROM dbo.T0010_COMPANY_MASTER WITH (NOLOCK) WHERE CMP_ID = @CMP_ID  
   
	IF SUBSTRING(@Domain_Name,1,1) <> '@'   
		SET @Domain_Name = '@' + @Domain_Name  
   
	DECLARE @len AS NUMERIC  
	SET @len = LEN(CAST (@emp_code AS VARCHAR(10)))  
   
	--If @len > 4  
		--Set @len = 4  -- Commented by Mihir 22122011  
 
	--Added by Mihir 22122011  
	IF @len > @No_Of_Digits  
		SET @len = @No_Of_Digits  
	--End Added by Mihir 22122011  
   
	SELECT @Branch_Code = Branch_Code FROM T0030_BRANCH_MASTER WITH (NOLOCK) WHERE Cmp_ID = @Cmp_ID AND Branch_ID = @Branch_ID   
	declare @Get_Emp_code  as varchar(40)		--Added BY GAdriwala 21012014
	declare @Get_Alpha_code  as varchar(10)		--Added BY GAdriwala 21012014
   
	set @Get_Emp_code = ''	--Added BY GAdriwala 21012014
	set @Get_Alpha_code = '' --Added BY GAdriwala 21012014
	
	-- Added BY Gadriwala Muslim 21012014
	exec Get_Employee_Code @cmp_ID,@Branch_ID,@Date_Of_Join,@Get_Emp_Code output,@Get_Alpha_Code output,1,@Desig_Id,@Cat_ID,@Type_ID ,@Date_OF_Birth
	if @Alpha_Code is NULL
	begin
		set @Alpha_Code = @Get_Alpha_Code
	end	
	 -- Comment By Muslim 21012014-------------------Start 
	 /*
	IF @Is_Auto_Alpha_Numeric_Code = 1  
		BEGIN    
			IF @Cmp_Code IS NULL  
				BEGIN    
					--Set @Alpha_Code = @Branch_Code  
					--Set @Alpha_Emp_Code =  @Branch_Code + REPLICATE ('0',4 - @len) + Cast(@Emp_code as Varchar(10))  
					--Above commented by Mihir And Below Added by Mihir 22122011  
					SET @Alpha_Code = @Branch_Code  
					SET @Alpha_Emp_Code =  @Branch_Code + REPLICATE ('0',@No_Of_Digits - @len) + CAST(@Emp_code AS VARCHAR(10))  
					--end of Added by Mihir 22122011  
				END  
			ELSE  
				BEGIN  
					--Set @Alpha_Code = @Cmp_Code + @Branch_Code  
					--Set @Alpha_Emp_Code = @Cmp_Code + @Branch_Code + REPLICATE ('0',4 - @len) + Cast(@Emp_code as Varchar(10))  
					--Above commented by Mihir And Below Added by Mihir 22122011  
					SET @Alpha_Code = @Cmp_Code + @Branch_Code  
					SET @Alpha_Emp_Code = @Cmp_Code + @Branch_Code + REPLICATE ('0',@No_Of_Digits - @len) + CAST(@Emp_code AS VARCHAR(10))  
					--end of Added by Mihir 22122011  
				END   
		END  
	ELSE  
		BEGIN  
			IF @Alpha_Code IS NOT NULL  
				BEGIN  
					--Set @Alpha_Emp_Code = @Alpha_Code  + REPLICATE ('0',4 - @len) + Cast(@Emp_code as Varchar(10))   
					--Above commented by Mihir And Below Added by Mihir 22122011  
					SET @Alpha_Emp_Code = @Alpha_Code  + REPLICATE ('0',@No_Of_Digits - @len) + CAST(@Emp_code AS VARCHAR(10))   
					--end of Added by Mihir 22122011  
				END  
			ELSE  
				BEGIN  
					--Set @Alpha_Emp_Code = Cast(@Emp_code as Varchar(10))  
					--Above commented by Mihir And Below Added by Mihir 22122011  
					SET @Alpha_Emp_Code = REPLICATE ('0',@No_Of_Digits - @len) + CAST(@Emp_code AS VARCHAR(10))  
					--end of Added by Mihir 22122011  
				END  
		END   */
   -- Comment By Muslim 21012014-------------------End
    --Added by Gadriwala Muslim 21012014 - Start
   
   if @Is_Auto_Alpha_Numeric_Code = 1
		begin
			if @Emp_code <> 0 and @Alpha_Code <> ''
				begin
							set @Alpha_Emp_Code = @Alpha_Code +  REPLICATE ('0',@No_Of_Digits - @len) + Cast(@Emp_code as Varchar(10)) 
				end	
			else
				begin
							 set @Alpha_Emp_Code =   REPLICATE ('0',@No_Of_Digits - @len) + Cast(@Emp_code as Varchar(10)) 
				end
		end
	else
		begin
						set @Alpha_Emp_Code =  REPLICATE ('0',@No_Of_Digits - @len) + Cast(@Emp_code as Varchar(10)) 
		end
		
	--Added by Gadriwala Muslim 21012014 - End
	SET @Emp_Full_Name = @Initial + ' ' + @Emp_First_Name + ' ' + @Emp_Second_Name + ' ' + @Emp_Last_Name 
	IF EXISTS(SELECT Emp_ID FROM dbo.T0080_EMP_MASTER WITH (NOLOCK) WHERE Cmp_ID = @Cmp_ID AND Alpha_Emp_Code = @Alpha_Emp_Code)  
		BEGIN
			SELECT @Emp_Id=Emp_Id FROM Dbo.T0080_Emp_Master WITH (NOLOCK) WHERE Cmp_ID = @Cmp_ID AND  Alpha_Emp_Code = @Alpha_Emp_Code   
			IF EXISTS(SELECT Emp_ID FROM dbo.T0080_EMP_MASTER WITH (NOLOCK) WHERE Cmp_ID= @Cmp_ID AND  Alpha_Emp_Code = @Alpha_Emp_Code AND Emp_ID <> @Emp_ID)  
				BEGIN  
					SET @Emp_ID = 0  
					RETURN    
				END  

		IF (@Work_Email<>'') --Mukti(10112020)check for duplicate Official Email ID
		BEGIN
			IF EXISTS(SELECT 1 FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE Work_Email =@Work_Email AND Alpha_Emp_Code <> @Alpha_Emp_Code AND Cmp_ID=@Cmp_ID)  
			BEGIN  
				INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,'Official Email ID already exist',@Desig_Name,'Official Email ID already exist',GETDATE(),'Employee Master','')  
				SET @Log_Status=1   
				RETURN  
			END  
		END

			UPDATE dbo.T0080_EMP_MASTER     
				SET  Pan_No = @Pan_No     
					,SSN_No = @PF_No    
					,SIN_No = @ESIC_No     
					,Date_Of_Birth = @Date_Of_Birth    
					,Marital_Status = @Marital_Status   
					,Gender = @Gender     
					,Nationality = @Nationality            
					,Street_1 = @Street_1    
					,City = @City     
					,STATE = @State     
					,Zip_Code = @Zip_Code    
					,Home_Tel_No = @Home_Tel_no   
					,Mobile_No = @Mobile_No    
					,Work_Tel_No = @Work_Tel_No   
					,Work_Email = @Work_Email    
					,Other_Email = @Other_Email   
					,Present_Street = @Present_Street   
					,Present_City = @Present_City     
					,Present_State = @Present_State    
					,Present_Post_Box = @Present_Post_Box   
					,Blood_Group = @Blood_Group  
					,Old_Ref_No=@Old_Ref_No  
					,Emp_Superior=@emp_Id_sup			-- Added by Alpesh 08-06-2011  
					,Enroll_No=@Enroll_No               -- Added by Mihir 24122011  
					,Father_name=@Father_Name           -- Added by Mihir 02012012  
					,Bank_ID = @Bank_ID                 -- Added by Mihir 21022012  
					,Ifsc_Code = @Emp_IFSC_No			-- Added by Mitesh 24022012  
					,Emp_Confirm_Date = @Confirm_Date	-- Added by Mitesh 24022012  
					,Is_LWF = @Is_LWF					-- Hardik 30/07/2012  
					,Segment_ID = @Segment_ID			-- Added By Gadriwala 03082013
					,Vertical_ID = @Vertical_ID			-- Added By Gadriwala 03082013
					,SubVertical_ID = @SubVertical_ID	-- Added By Gadriwala 03082013
					,SubBranch_ID = @SubBranch_ID		-- Added By Gadriwala 03082013
					,GroupJoiningDate = @Group_of_Joining --Added By Gadriwala 03082013
			    WHERE Emp_Id = @Emp_Id AND Cmp_Id = @Cmp_ID  
        
        SELECT @Increment_Id = ISNULL(MAX(Increment_Id),0) FROM dbo.T0095_Increment WITH (NOLOCK) WHERE Emp_Id = @Emp_Id AND Cmp_Id = @Cmp_Id AND Increment_Effective_date <= GETDATE()  
  
		IF @Increment_Id > 0 --Changed by Falak on 02-MAY-2011  
			BEGIN    
				UPDATE dbo.T0095_Increment 
					SET  Wages_Type = @Wages_Type  
						,Salary_Basis_On = @Salary_Basis_On  
						,Payment_Mode = @Payment_Mode  
						,Inc_Bank_Ac_No = @Inc_Bank_Ac_No  
						,Emp_OT = @Emp_OT  
						,Emp_OT_Min_Limit = @Emp_OT_Min_Limit  
						,Emp_OT_Max_Limit = @Emp_OT_Max_Limit  
						,Emp_Late_Mark = @Emp_Late_Mark  
						,Emp_Full_Pf = @Emp_Full_Pf  
						,Emp_PT = @Emp_PT  
						,Emp_Fix_Salary = @Emp_Fix_Salary
						,SalDate_Id = @Salary_Cycle_ID		-- Added By Hiral 14 August, 2013 
						,Segment_ID = @Segment_ID			-- Added By Hiral 22 August, 2013 
						,Vertical_ID = @Vertical_ID			-- Added By Hiral 22 August, 2013
						,SubVertical_ID = @SubVertical_ID	-- Added By Hiral 22 August, 2013
						,SubBranch_ID = @SubBranch_ID		-- Added By Hiral 22 August, 2013
						,Emp_Auto_vpf = @Cmp_Full_Pf  -- Added by rohit on 06092013
					WHERE Emp_Id = @Emp_Id AND Increment_Id = @Increment_Id AND Cmp_Id = @Cmp_Id   
				
				-- Added By Hiral 14 Hiral, 2013 (Start) 
				If Exists (Select Tran_ID From T0095_Emp_Salary_Cycle WITH (NOLOCK) Where Emp_Id = @Emp_Id)
					Begin	
						If @Salary_Cycle_ID = 0
							Begin
								Delete From T0095_Emp_Salary_Cycle 
									Where Emp_Id = @Emp_Id 
										And Effective_date = (Select Min(Effective_date) From T0095_Emp_Salary_Cycle WITH (NOLOCK) Where Emp_Id = @Emp_Id)
							End
						Else
							Begin
								Update T0095_Emp_Salary_Cycle
									Set SalDate_id = @Salary_Cycle_ID
									Where Emp_Id = @Emp_Id 
										And Effective_date = (Select Min(Effective_date) From T0095_Emp_Salary_Cycle WITH (NOLOCK) Where Emp_Id = @Emp_Id)
							End
					End
				Else
					Begin
						If @Salary_Cycle_ID <> 0
							Begin
								Declare @Temp_Effective_date As Datetime
								Set @Temp_Effective_date = DATEADD(month,month(@Date_Of_Join)-1,DATEADD(year,year(@Date_Of_Join)-1900,0))
			
								INSERT INTO T0095_Emp_Salary_Cycle
										  (Cmp_id, Emp_id, SalDate_id, Effective_date)
									VALUES (@Cmp_id,@Emp_id,@Salary_Cycle_id,@Temp_Effective_date)
							End
					End
				-- Added By Hiral 14 Hiral, 2013 (End)
			END   
     
		--Alpesh 04-Apr-2012 
		IF NOT EXISTS(SELECT Row_ID FROM T0090_EMP_REPORTING_DETAIL WITH (NOLOCK) WHERE Cmp_ID=@Cmp_ID AND Emp_ID=@Emp_ID)  
			BEGIN  
				IF @emp_Id_sup IS NOT NULL  
					BEGIN  
						EXEC P0090_EMP_REPORTING_DETAIL 0,@Emp_ID,@Cmp_ID,'Supervisor',@emp_Id_sup,'Direct','i',0,0, '',@Date_OF_Join 
					END  
			END      
		-- End               
		END
	ELSE  
		BEGIN  
			DECLARE @Count AS NUMERIC(18,0) ----Added by Hasmukh for employee License  14072011  
			DECLARE @Emp_LCount NUMERIC  
			DECLARE @ErrString VARCHAR(1000)  
   
			SELECT @Count =COUNT(Emp_ID) FROM dbo.T0080_EMP_MASTER WITH (NOLOCK) WHERE  Emp_Left <> 'y'   --Changed By Gadriwala 05092013
			--SELECT @ErrString = 'Employee Limit Exceed Contact Administrator: Total Employee =' + ' ' + CAST(@Count AS VARCHAR(18))      
  
			-- Add By Jignesh 20_sep_2012
			-- SELECT @Emp_LCount = Emp_License_Count FROM dbo.Emp_Lcount      
			SELECT @Emp_LCount = dbo.decrypt(Emp_License_Count) FROM dbo.Emp_Lcount  
     
			IF @Count > @Emp_LCount  
				BEGIN  
					SET @Emp_ID = 0  
					--Added By Gadriwala Muslim  05092013 - Start
					INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,'Employee Limit Exceed Contact Administrator: Total Employee =' ,CAST(@Count AS VARCHAR(18)),'Please Contact with Administration',GETDATE(),'Employee Import','')  
					SET @Log_Status= 90
					--Added By Gadriwala Muslim  05092013 - End
				 
					RETURN   
				END
				
			SELECT @Emp_ID = ISNULL(MAX(Emp_ID),0) + 1  FROM dbo.T0080_EMP_MASTER WITH (NOLOCK)
			SELECT @Adult_No = ISNULL(MAX(Worker_Adult_No),0) + 1 FROM dbo.T0080_EMP_MASTER WITH (NOLOCK) WHERE Cmp_ID=@Cmp_ID     
     
			-- Added By Alpesh on 25-05-2011 for first time login change password dialogbox for employee   
			IF EXISTS (SELECT Module_Id FROM T0011_module_detail WITH (NOLOCK) WHERE Cmp_Id=@Cmp_ID AND chg_pwd=1)  
				BEGIN  
					SET @Chg_Pwd=1  
				END  
			----------------------End----------------------    
     
		 --ADDED BY MUKTI(09072020)START	
			DECLARE @AGE INT
			DECLARE @MaxAgeLimit INT
			SET @AGE = dbo.F_GET_AGE (@Date_Of_Birth,GETDATE(),'N','N')
			SELECT @MaxAgeLimit = Setting_Value from T0040_SETTING WITH (NOLOCK) where cmp_id = @Cmp_ID and Setting_Name='Maximum Age Limit for Employee Joining'
			IF @AGE >@MaxAgeLimit
			BEGIN
				SET @Emp_ID = 0
				SET @ErrString='@@Employee Age is more than ' + ' ' +  @MaxAgeLimit  + ' ' + ' years@@'
				RAISERROR (@ErrString, 16, 2)
				RETURN
			END
		--ADDED BY MUKTI(09072020)END

			INSERT INTO dbo.T0080_EMP_MASTER  
					(Emp_ID, Cmp_ID, Branch_ID, Cat_ID, Grd_ID, Dept_ID, Desig_Id, TYPE_ID, Shift_ID, Bank_ID, Emp_code,Initial, Emp_First_Name, Emp_Second_Name,   
					Emp_Last_Name, Curr_ID, Date_Of_Join, SSN_No, SIN_No, Dr_Lic_No, Pan_No, Date_Of_Birth, Marital_Status, Gender, Dr_Lic_Ex_Date, Nationality,   
					Loc_ID, Street_1, City, STATE, Zip_code, Home_Tel_no, Mobile_No, Work_Tel_No, Work_Email, Other_Email, Basic_Salary, Image_Name,Emp_Full_Name,  
					Emp_Left,Present_Street,Present_City,Present_State,Present_Post_Box ,Blood_Group,Enroll_No,Tally_Led_Name,Religion,Height,Emp_Mark_Of_Identification  
					,Despencery,Doctor_Name,DespenceryAddress,Insurance_No,Is_Gr_App,Is_Yearly_Bonus,Yearly_Leave_days,Yearly_Leave_Amount,Yearly_bonus_Per,Yearly_bonus_Amount,  
					Worker_Adult_No,Father_name,Ifsc_Code,Emp_Confirm_Date,IS_ON_Probation,Old_Ref_No,Chg_Pwd,Alpha_Code,Alpha_Emp_Code,Emp_Superior,Is_LWF
					,Segment_ID,Vertical_ID,SubVertical_ID,subBranch_ID,GroupJoiningDate,System_Date)  
				VALUES (@Emp_ID,@Cmp_ID,@Branch_ID,@Cat_ID,@Grd_ID,@Dept_ID,@Desig_Id,@Type_ID,@Shift_ID,@Bank_ID,@Emp_code,@Initial,@Emp_First_Name,@Emp_Second_Name,  
					@Emp_Last_Name,@Curr_ID,@Date_Of_Join,@PF_No,@ESIC_No,'',@Pan_No,@Date_Of_Birth,@Marital_Status,@Gender,NULL,@Nationality,  
					@Loc_ID,@Street_1,@City,@State,@Zip_code,@Home_Tel_no,@Mobile_No,@Work_Tel_No,@Work_Email,@Other_Email,@Basic_Salary,'',@Emp_Full_Name,  
					'N',@Present_Street,@Present_City,@Present_State,@Present_Post_Box,@Blood_Group,@Enroll_No,NULL,NULL,NULL,NULL,  
					NULL,NULL,NULL,NULL,0,0.0,0.0,0.0,0.0,0.0,@Adult_No,@Father_Name,@Emp_IFSC_No,@Confirm_Date,@Probation,@Old_Ref_No,@Chg_Pwd,@Alpha_Code,@Alpha_Emp_Code,@emp_Id_sup,@Is_LWF
					,@Segment_ID,@Vertical_ID,@SubVertical_ID,@SubBranch_ID,@Group_of_Joining,GETDATE())  
   
			SELECT @Default_Weekof = Default_Holiday FROM dbo.T0010_COMPANY_MASTER WITH (NOLOCK) WHERE Cmp_Id = @Cmp_ID  
   
			--set @loginname = cast(@Emp_Code as varchar(16)) + @Domain_Name  
			--set @loginname = cast(@Alpha_Emp_Code as varchar(50)) + @Domain_Name  
			
			IF @Alpha_Emp_Code IS NOT NULL  
				BEGIN  
					SET @loginname = CAST(@Alpha_Emp_Code AS VARCHAR(50)) + @Domain_Name  
				END  
			ELSE  
				BEGIN  
					SET @loginname = CAST(@Emp_Code AS VARCHAR(10)) + @Domain_Name  
				END   
   
			-- added by mihir 10112011
			IF NOT EXISTS(SELECT Row_ID FROM T0090_EMP_REPORTING_DETAIL WITH (NOLOCK) WHERE Cmp_ID=@Cmp_ID AND Emp_ID=@Emp_ID)  
				BEGIN  
					IF @emp_Id_sup IS NOT NULL  
						BEGIN  
							EXEC P0090_EMP_REPORTING_DETAIL 0,@Emp_ID,@Cmp_ID,'Supervisor',@emp_Id_sup,'Direct','i',0,0, '',@Date_OF_Join 
						END  
				END
			--end  
     
     
			EXEC p0011_Login @Login_ID OUTPUT,@Cmp_Id,@loginname,'VuMs/PGYS74=',@Emp_ID,NULL,NULL,'I',2  
			EXEC P0110_EMP_LEFT_JOIN_TRAN @EMP_ID,@CMP_ID,@Date_Of_Join,'','',0  
			EXEC P0100_EMP_SHIFT_INSERT @emp_ID,@cmp_ID,@Shift_ID,@Date_of_Join,NULL    
			EXEC P0095_INCREMENT_INSERT @Increment_ID OUTPUT ,@Emp_ID,@Cmp_ID,@Branch_ID,@Cat_ID,@Grd_ID,@Dept_ID,@Desig_Id,@Type_ID,@Bank_ID
				,@Curr_ID,@Wages_Type,@Salary_Basis_On,@Basic_Salary,@Gross_salary,'Joining',@Date_OF_Join,@Date_OF_Join,@Payment_Mode
				,@Inc_Bank_AC_No,@Emp_OT,@Emp_OT_Min_Limit,0,0,0,0,0,'',@Emp_LATE_MARK,@Emp_Full_PF,@Emp_PT,@Emp_Fix_Salary,0,'',0,1,@Login_ID,0
				,NULL,@emp_Id_sup,1,0,0,0,0,0,0,0,0,0,'','00:00',0,'','',0,@WeekDay_OT_Rate,@Weekoff_OT_Rate,@Holiday_OT_Rate,0,0,0,0,0,0,0
				--,0	-- Commented By Hiral 14 August, 2013
				,@Salary_Cycle_ID		-- Added By Hiral 14 August, 2013
				,@Cmp_Full_PF
				,@Segment_ID ,@Vertical_ID,@SubVertical_ID,@SubBranch_ID
			EXEC P0100_EMP_GRADEWISE_ALLOWANCE @Cmp_ID,@Emp_ID,@Grd_ID,@Date_Of_Join,@Increment_ID  
			print 'k'
			EXEC SP_Get_Advance_Leave_Details @Cmp_ID=@Cmp_ID,@Type_ID=	@Type_ID,@Join_Date=@Date_OF_Join --Mukti(02082017)
			IF ISNULL(@Default_Weekof,'') <> ''  
				EXEC P0100_WEEKOFF_ADJ 0,@Cmp_ID,@Emp_ID,@Date_Of_Join,@Default_Weekof,'','','','',0,'I'  
		
			UPDATE dbo.T0080_EMP_MASTER SET Increment_ID = @Increment_ID  WHERE Emp_ID = @Emp_ID                                
		END 
RETURN

