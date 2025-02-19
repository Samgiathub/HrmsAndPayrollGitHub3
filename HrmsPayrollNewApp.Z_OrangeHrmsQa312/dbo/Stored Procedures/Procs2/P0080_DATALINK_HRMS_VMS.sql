
CREATE PROCEDURE [dbo].[P0080_DATALINK_HRMS_VMS]
	@CMP_ID					NUMERIC(18, 0), 
	@BRANCH_ID				NUMERIC(18, 0), 
	@EMP_ID					NUMERIC(18, 0), 
	@DEPT_ID				NUMERIC(18, 0), 
	@DESIG_ID				NUMERIC(18, 0), 
	@LOC_ID					NUMERIC(18, 0), 
	@STATE_Name				Varchar(50),
	@CITY_Name				Varchar(50),
	@Login_Alias			varchar(100),
	@tran_type				char(1)
AS

BEGIN
	SET NOCOUNT ON

	-- Country/Location Master
	IF NOT EXISTS(SELECT 1 FROM T0001_LOCATION_MASTER TLM INNER JOIN  [VMS].[DBO].[Master_Country] MC ON TLM.Loc_name = MC.Country_Name WHERE TLM.Loc_ID = @LOC_ID)
	BEGIN
		
		DECLARE @MAXCOUNTRYCOUNT NUMERIC(18,0)
		SELECT @MAXCOUNTRYCOUNT = CASE WHEN (SELECT COUNT(1) FROM [VMS].[DBO].[MASTER_COUNTRY]) > 0 THEN MAX(COUNTRY_ID + 1) ELSE 1 END FROM [VMS].[DBO].[MASTER_COUNTRY] 

		INSERT INTO [VMS].[dbo].[Master_Country]  (Country_ID,Country_Name,Comments,CreatedBy,DateCreated,PayRoll_CountryId)
		SELECT @maxCountryCount ,Loc_name ,Loc_name as Comments,1 as CREATEDBY ,GETDATE() as DATECREATED,@LOC_ID FROM T0001_LOCATION_MASTER where Loc_ID = @LOC_ID
	END
	
	-- State Master
	IF NOT EXISTS(SELECT 1 FROM T0020_STATE_MASTER TSM INNER JOIN  [VMS].[dbo].[Master_State] MS ON TSM.State_Name = MS.State_Name WHERE TSM.State_Name = @STATE_Name)
	BEGIN
		DECLARE @MAXSTATECOUNT NUMERIC(18,0)
		SELECT @MAXSTATECOUNT = CASE WHEN (SELECT COUNT(1) FROM  [VMS].[DBO].[MASTER_STATE]) > 0 THEN MAX(STATE_ID + 1) ELSE 1 END FROM  [VMS].[DBO].[MASTER_STATE]

		INSERT INTO [VMS].[dbo].[Master_State]  (State_ID,State_Name,Country_ID,Comments,CreatedBy,DateCreated)
		SELECT @maxStateCount ,State_Name ,Loc_ID ,State_Name as Comments,1 as CREATEDBY ,GETDATE() as DATECREATED FROM T0020_STATE_MASTER where State_Name = @STATE_Name and Cmp_ID = @CMP_ID
	END
	
	-- City Master
	IF NOT EXISTS(SELECT 1 FROM T0030_CITY_MASTER TCM INNER JOIN  [VMS].[dbo].[Master_City] MC ON TCM.City_Name = MC.City_Name WHERE TCM.City_Name = @CITY_Name)
	BEGIN
	
		DECLARE @maxCityCount Numeric(18,0)
		SELECT @maxCityCount = case when (select count(1) from [VMS].[dbo].[Master_City]) > 0 then max(City_ID + 1) else 1 END FROM [VMS].[dbo].[Master_City]
		
		-- Getting State ID
		DECLARE @cityStateID  NUMERIC(18,0)
		SELECT @cityStateID = State_ID  FROM [VMS].[DBO].[MASTER_STATE] where State_Name = @STATE_Name
		
		IF EXISTS (SELECT 1 FROM T0030_CITY_MASTER WHERE Replace(City_Name,' ','') = @CITY_Name and Cmp_ID = @CMP_ID)
		BEGIN
			INSERT INTO [VMS].[dbo].[Master_City]  (City_ID,City_Name,City_Code,State_ID,CreatedBy,DateCreated)
			SELECT @maxCityCount ,Replace(City_Name,' ','') ,Replace(City_Name,' ','') as City_Code ,@cityStateID ,1 as CREATEDBY ,GETDATE() as DATECREATED FROM T0030_CITY_MASTER where Replace(City_Name,' ','') = @CITY_Name and Cmp_ID = @CMP_ID
		END
	END

	DECLARE @COUNTRY1 NUMERIC(18,0)
	SELECT @COUNTRY1 = COUNTRY_ID FROM  [VMS].[DBO].[MASTER_COUNTRY] WHERE Country_ID = @LOC_ID  

	DECLARE @STATEID1 NUMERIC(18,0)
	SELECT @STATEID1 = STATE_ID FROM  [VMS].[DBO].[MASTER_STATE] WHERE STATE_NAME = @STATE_NAME  

	DECLARE @CITYID1 NUMERIC(18,0)
	IF EXISTS (SELECT 1 FROM [VMS].[DBO].[MASTER_CITY] WHERE CITY_NAME = @CITY_NAME)
	BEGIN
			SELECT @CITYID1 = CITY_ID FROM [VMS].[DBO].[MASTER_CITY] WHERE CITY_NAME = @CITY_NAME
	END
	ELSE
	BEGIN	
			SET @CITYID1 = 0
	END

	DECLARE @BranchID1 NUMERIC(18,0)
	IF EXISTS (SELECT 1 FROM [VMS].[DBO].[Master_Branch] where PayRoll_BranchId = @BRANCH_ID)
	BEGIN
			SELECT @BranchID1 = Branch_ID FROM [VMS].[DBO].[Master_Branch] where PayRoll_BranchId = @BRANCH_ID
	END

	DECLARE @DeptID1 NUMERIC(18,0)
	IF EXISTS (SELECT 1 FROM [VMS].[DBO].[MASTER_DEPARTMENT] where PayRoll_DeptId = @DEPT_ID)
	BEGIN
			SELECT @DeptID1 = Department_ID FROM [VMS].[DBO].[MASTER_DEPARTMENT] where PayRoll_DeptId = @DEPT_ID
	END

	DECLARE @DesgID1 NUMERIC(18,0)
	IF EXISTS (SELECT 1 FROM [VMS].[DBO].[Master_Desgination] where PayRoll_DesgId = @DESIG_ID)
	BEGIN
			SELECT @DesgID1 = Designation_ID FROM [VMS].[DBO].[Master_Desgination] where PayRoll_DesgId = @DESIG_ID
	END
	
	-- Branch Master
	IF NOT EXISTS(SELECT 1 FROM T0030_BRANCH_MASTER TBM INNER JOIN [VMS].[dbo].[Master_Branch] MB ON TBM.Branch_Name = MB.Branch_Name WHERE TBM.Branch_ID = @BRANCH_ID)
	BEGIN
		DECLARE @MAXBRANCHCOUNT NUMERIC(18,0)
		SELECT @MAXBRANCHCOUNT = CASE WHEN (SELECT COUNT(1) FROM [VMS].[DBO].[MASTER_BRANCH]) > 0 THEN MAX(BRANCH_ID + 1) ELSE 1 END FROM [VMS].[DBO].[MASTER_BRANCH]
		
		INSERT INTO [VMS].[dbo].[Master_Branch]  (Branch_ID,Branch_Name,Branch_Code,Login_ID ,Cmp_ID ,Trans_Date, Branch_Country_ID ,Branch_State_ID ,Branch_City_ID,Branch_Address,PayRoll_BranchId)
		SELECT @maxBranchCount ,Branch_Name ,Branch_Code ,1 as Login_ID ,1 ,GETDATE() as DATECREATED ,@COUNTRY1,@STATEID1,@CITYID1,Branch_Address,@BRANCH_ID 
		FROM T0030_BRANCH_MASTER where Branch_ID = @BRANCH_ID and Cmp_ID = @CMP_ID
	END
	-- End Branch Master

	--Desgination Master
	IF NOT EXISTS(SELECT 1 FROM T0040_DESIGNATION_MASTER TDM INNER JOIN  [VMS].[dbo].[Master_Desgination] MD ON TDM.Desig_Name = MD.Designation_Name WHERE tdm.Desig_ID = @DESIG_ID)
	BEGIN
		DECLARE @maxDesgID Numeric(18,0)
		SELECT @maxDesgID = CASE WHEN (SELECT COUNT(1) FROM [VMS].[dbo].[Master_Desgination]) > 0 THEN max(Designation_ID + 1) ELSE 1 END FROM [VMS].[dbo].[Master_Desgination]

		INSERT INTO [VMS].[dbo].[Master_Desgination] (Designation_ID,Designation_Name,Comments,CreatedBy,DateCreated,Cmp_ID,PayRoll_DesgId)
		SELECT @maxDesgID ,Desig_Name ,Desig_Name as Comments,1 as CREATEDBY ,GETDATE() as DATECREATED ,1 ,@DESIG_ID FROM T0040_DESIGNATION_MASTER where Desig_ID = @DESIG_ID
	END
	
	--Departement Master
	IF NOT EXISTS(SELECT 1 FROM T0040_DEPARTMENT_MASTER TDM INNER JOIN  [VMS].[DBO].[MASTER_DEPARTMENT] MD ON TDM.DEPT_NAME = MD.DEPARTMENT_NAME WHERE tdm.Dept_Id = @DEPT_ID)
	BEGIN
		DECLARE @maxDeptID Numeric(18,0)
		SELECT @maxDeptID = CASE WHEN (SELECT COUNT(1) FROM [VMS].[DBO].[MASTER_DEPARTMENT]) > 0 THEN max(Department_ID + 1) ELSE 1 END FROM [VMS].[DBO].[MASTER_DEPARTMENT] 
	
		INSERT INTO [VMS].[DBO].[MASTER_DEPARTMENT] (DEPARTMENT_ID,DEPARTMENT_NAME,Comments,CreatedBy,DateCreated,Cmp_ID, PayRoll_DeptId)
		SELECT @maxDeptID ,Dept_Name ,Dept_Name as Comments,1 as CREATEDBY ,GETDATE() as DATECREATED ,1 ,@DEPT_ID FROM T0040_DEPARTMENT_MASTER where Dept_Id = @DEPT_ID
	END
	
	----Company Master
	----Declare @CMP_ID Numeric(18,0) = 54
	--IF NOT EXISTS(SELECT 1 FROM T0010_COMPANY_MASTER TCM INNER JOIN  [VMS].[dbo].[Company] C ON TCM.Cmp_Name = C.CompanyName WHERE TCM.Cmp_Id = @CMP_ID)
	--BEGIN
	--	--PRINT '7) Company INSERT'
	--	--DECLARE @maxCmpID Numeric(18,0)
	--	--SELECT @maxCmpID = max(Company_ID + 1) FROM [VMS].[dbo].[Company]
	--	DECLARE @maxCmpID Numeric(18,0)
	--	SELECT @maxCmpID = CASE WHEN (SELECT COUNT(1) FROM [VMS].[dbo].[Company]) > 0 THEN max(Company_ID + 1) ELSE 1 END  FROM [VMS].[dbo].[Company]
						
	--	INSERT INTO [VMS].[dbo].[Company] (Company_ID ,CompanyName ,[Address] ,Mobile ,Email ,Country_ID ,Domain ,Logo ,Sys_Date)
	--	SELECT @maxCmpID ,Cmp_Name ,Cmp_Address ,Cmp_Phone ,Cmp_Email ,Loc_ID ,Domain_Name ,Image_name ,GETDATE() as SysDate FROM T0010_COMPANY_MASTER where Cmp_Id = @CMP_ID
	--END
	--END Company Master

	If @tran_type  = 'I'
	BEGIN

			IF NOT EXISTS(SELECT 1 FROM T0080_EMP_MASTER TEM INNER JOIN  [VMS].[dbo].[Master_Employee] E ON TEM.Emp_First_Name = E.Emp_Fname and TEM.Emp_Second_Name = e.Emp_Mname and TEM.Emp_Last_Name = E.Emp_Lname WHERE TEM.Emp_ID = @EMP_ID)
			BEGIN
			
				DECLARE @maxEmpID Numeric(18,0)
				SELECT @maxEmpID =  CASE WHEN (SELECT COUNT(1) FROM [VMS].[dbo].[Master_Employee]) > 0 THEN max(Emp_ID + 1) ELSE 1 END   FROM [VMS].[dbo].[Master_Employee]
			
				INSERT INTO [VMS].[dbo].[Master_Employee] (Emp_ID , Initial ,Emp_Code ,Emp_Fname ,Emp_Mname ,Emp_Lname ,Emp_Address ,Pincode ,Mobile_No ,Emp_Email 
				,Country_ID ,DOB ,DOJ ,Blood_Group ,Gender ,Branch_ID ,Department_ID ,Designation_ID ,Emp_Left ,cmp_id ,Trans_Date,PayRoll_EmpId,Role_ID,Login_Alias)--PayRoll_EmpId
				SELECT @maxEmpID ,Initial ,Alpha_Emp_Code ,Emp_First_Name ,Emp_Second_Name ,Emp_Last_Name ,Street_1 ,Zip_code ,Mobile_No ,Work_Email ,Loc_ID 
					,Date_Of_Birth ,Date_Of_Join ,Blood_Group ,CASE WHEN GENDER = 'M' THEN 'Male' ELSE 'Female' END AS GENDER ,@BranchID1 ,@DeptID1 ,@DesgID1 
					,case when Emp_Left = 'N' then 0 else 1 end as Emp_left ,1 , GETDATE() as TransDate,Emp_ID ,2,isnull(@Login_Alias,'')
				FROM T0080_EMP_MASTER where Emp_ID = @EMP_ID
			END
	END
	Else If @Tran_Type = 'U'
	BEGIN		
		Update [VMS].[dbo].[Master_Branch] set Branch_State_ID = @STATEID1 , Branch_City_ID = @CITYID1 where PayRoll_BranchId = @BRANCH_ID
	
		UPDATE VMS
		SET 
		VMS.Login_Alias = isnull(@Login_Alias,''),
		VMS.Country_ID = @Country1, 
		VMS.State_ID  = @stateID1, 
		VMS.CITY_ID  = @cityID1, 
		VMS.Branch_ID = @BranchID1, 
		VMS.Designation_ID = @DesgID1, 
		VMS.Department_ID = @DeptID1,
		VMS.Blood_Group =  Emp.Blood_Group,
		VMS.Mobile_No = Emp.Mobile_No,
		VMS.Emp_Address = Emp.Present_Street,
		VMS.Phone_No = Emp.Work_Tel_No,
		VMS.Trans_Date = GETDATE(),
		VMS.Emp_Email = Emp.Work_Email,
		VMS.DOB = Emp.Date_Of_Birth,
		VMS.DOJ = Emp.Date_Of_Join,
		vms.Initial = Emp.Initial,
		VMS.Emp_Fname = Emp.Emp_First_Name,
		VMS.Emp_Lname = Emp.Emp_Last_Name,
		VMS.Emp_Mname = Emp.Emp_Second_Name,
		VMS.Gender = Case when Emp.Gender = 'M' then 'Male' else 'Female' end,
		Vms.Photo = emp.Image_Name
		FROM [VMS].[DBO].[MASTER_EMPLOYEE] VMS INNER JOIN T0080_EMP_MASTER EMP
		ON VMS.PayRoll_EmpId = Emp.Emp_ID
		Where PayRoll_EmpId = @EMP_ID AND VMS.CMP_ID = @CMP_ID
	END
END

