

 
 ---25/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0500_Lead_Login_Check]
	@Username	varchar(50) = ''           
	,@Password	varchar(50) = ''           
	,@EmpID NUMERIC(18,0) = 0
	,@IPAdd	varchar(20) = ''     
	,@Result VARCHAR(300) = '' OUTPUT
	,@loginType int = 1
AS
	BEGIN

	SET NOCOUNT ON 
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ARITHABORT ON
	
	IF @loginType = 1 
			BEGIN
				IF EXISTS(SELECT 1 FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE Emp_ID = @EmpID)
					BEGIN
						
						SELECT ISNULL(TEM.Emp_ID,0) AS 'Emp_ID',ISNULL(TEM.Emp_Full_Name,'') AS 'Emp_Full_Name',ISNULL(TEM.Emp_code,0) AS 'Emp_code'
						, ISNULL(TEM.Alpha_Emp_Code,'') AS 'Alpha_Emp_Code', ISNULL(TEM.Cmp_ID,0) AS 'Cmp_ID',ISNULL(TCM.Cmp_Name,'') AS 'Cmp_Name'
						, ISNULL(TL.Login_ID,0) AS 'Login_ID',ISNULL(TL.Login_Name,'') AS 'Login_Name',ISNULL(TL.Login_Rights_ID,0) AS 'Login_Rights_ID'
						, ISNULL(TL.Login_Alias,'') AS 'Login_Alias', ISNULL(TEM.Image_Name,'') AS 'Image_Name',ISNULL(TEM.Gender,'') AS 'EmpGender'
						, ISNULL(TEM.Desig_Id,0) AS 'Desig_Id', ISNULL(TDM.Desig_Name,'') AS 'Desig_Name'
						, ISNULL(TDP.Dept_Name,'') AS 'Dept_Name', ISNULL(TBR.Branch_Name,'') AS 'Branch_Name'
						, ISNULL(TEP.Privilege_Id,0) AS 'Privilege_ID'
						
						FROM T0080_EMP_MASTER TEM WITH (NOLOCK)
						INNER JOIN T0010_COMPANY_MASTER TCM WITH (NOLOCK) ON TEM.Cmp_ID = TCM.Cmp_Id
						INNER JOIN T0011_LOGIN TL WITH (NOLOCK) ON TEM.Emp_ID = TL.Emp_ID
						LEFT JOIN (
								SELECT s.* FROM T0095_INCREMENT s WITH (NOLOCK)
								INNER JOIN(								
										SELECT MAX(t.Increment_ID) AS 'Increment_ID',t.Emp_ID FROM T0095_INCREMENT t WITH (NOLOCK)
										INNER JOIN(
											SELECT Emp_ID,MAX(Increment_Effective_Date) AS 'Increment_Effective_Date'
											FROM T0095_INCREMENT WITH (NOLOCK)
											GROUP BY Emp_ID
										)q ON t.Increment_Effective_Date = q.Increment_Effective_Date AND q.Emp_ID = t.Emp_ID
										GROUP BY t.Emp_ID
									)I ON 	s.Increment_ID = I.Increment_ID								
							)TIC ON TEM.Emp_ID = TIC.Emp_ID
						LEFT JOIN T0040_DESIGNATION_MASTER TDM WITH (NOLOCK) ON TDM.Desig_ID = ISNULL(TIC.Desig_Id , TEM.Desig_Id)
						LEFT JOIN T0040_DEPARTMENT_MASTER TDP WITH (NOLOCK) ON TDP.Dept_Id = ISNULL(TIC.Dept_ID, TEM.Dept_ID)
						LEFT JOIN T0030_BRANCH_MASTER TBR WITH (NOLOCK) ON TBR.Branch_ID = ISNULL(TIC.Branch_ID, TEM.Branch_ID)
						LEFT JOIN T0090_EMP_PRIVILEGE_DETAILS TEP WITH (NOLOCK) ON TL.Login_ID = TEP.Login_Id
						WHERE TEM.Emp_ID = @EmpID
						
						SET @Result = '1:Successfully logged in to Lead System'
					
					END
				ELSE 
					BEGIN
						SET @Result = '0:There is no such user Exists.'
					END
				
			END
		ELSE IF @loginType = 2
			BEGIN
				DECLARE @Cmp_Id					numeric(18,0) 
				DECLARE @dateformate			numeric(18,0) 
				DECLARE @Emp_ID					numeric
  				DECLARE @Branch_ID				numeric
  				DECLARE @Login_Rights_ID		numeric
  				DECLARE @Cmp_Name				varchar(100)
  				DECLARE @Image_name				varchar(200)        
  				DECLARE @Branch_Name			varchar(100)         
  				DECLARE @tdate					datetime 
  				DECLARE @ydate					datetime 
  				DECLARE @Predate				datetime   
  				DECLARE @Get_Login_ID			numeric(18,2) 
  				DECLARE @Row_ID					numeric(18,2) 
  				DECLARE @Login_type				numeric(1,0)  
  				DECLARE @m_status				numeric(18,0)
  				DECLARE @From_Date				DateTime 
  				DECLARE @Login_In_out			Int
  				DECLARE @Login_In_out_Popup		Int
  				DECLARE @Privilege_Id			Int
  				DECLARE @Privilege_Type			Int
  				DECLARE @is_GroupOfCompany		Int
  				DECLARE @pBranch_id				Int
  				DECLARE @pBranch_id_multi		varchar(Max)
  				DECLARE @Emp_Search_Type		int
  				DECLARE @Dept_Id				numeric(18,0)
  				DECLARE @PVertical_ID_Multi		Varchar(Max)
  				DECLARE @PSubVertical_id_multi	Varchar(Max)
  				DECLARE @Timesheet_status		numeric(18,0)
  				DECLARE @pDepartment_Id_Multi	VARCHAR(MAX)
  				DECLARE @Module_Enable			VARCHAR(MAX)
  				DECLARE @Email_Setting			VARCHAR(MAX)
  				DECLARE @MacAddress				VARCHAR(100)
  				DECLARE @InterNetIP				Varchar(100)
			  	
			  	
			  	EXEC SP_CheckLogin_Common 
						@Username					=	@Username
						, @Password					=	@Password
						, @IPAdd					=	@IPAdd
						, @Cmp_Id					=	@Cmp_Id					OUTPUT
						, @dateformate				=	@dateformate			OUTPUT
						, @Emp_ID					=	@Emp_ID					OUTPUT
						, @Branch_ID				=	@Branch_ID				OUTPUT
						, @Login_Rights_ID			=	@Login_Rights_ID		OUTPUT
						, @Cmp_Name					=	@Cmp_Name				OUTPUT
						, @Image_name				=	@Image_name				OUTPUT
						, @Branch_Name				=	@Branch_Name			OUTPUT
						, @tdate					=	@tdate					OUTPUT
						, @ydate					=	@ydate					OUTPUT
						, @Predate					=	@Predate				OUTPUT
						, @Get_Login_ID				=	@Get_Login_ID			OUTPUT
						, @Row_ID					=	@Row_ID					OUTPUT
						, @Login_type				=	@Login_type				OUTPUT
						, @m_status					=	@m_status				OUTPUT
						, @From_Date				=	@From_Date				OUTPUT
						, @Login_In_out				=	@Login_In_out			OUTPUT
						, @Login_In_out_Popup		=	@Login_In_out_Popup		OUTPUT
						, @Privilege_Id				=	@Privilege_Id			OUTPUT
						, @Privilege_Type			=	@Privilege_Type			OUTPUT
						, @is_GroupOfCompany		=	@is_GroupOfCompany		OUTPUT
						, @pBranch_id				=	@pBranch_id				OUTPUT
						, @pBranch_id_multi			=	@pBranch_id_multi		OUTPUT
						, @Emp_Search_Type			=	@Emp_Search_Type		OUTPUT
						, @Dept_Id					=	@Dept_Id				OUTPUT
						, @PVertical_ID_Multi		=	@PVertical_ID_Multi		OUTPUT
						, @PSubVertical_id_multi	=	@PSubVertical_id_multi	OUTPUT
						, @Timesheet_status			=	@Timesheet_status		OUTPUT
						, @pDepartment_Id_Multi		=	@pDepartment_Id_Multi	OUTPUT
						, @Module_Enable			=	@Module_Enable			OUTPUT
						, @Email_Setting			=	@Email_Setting			OUTPUT
						, @MacAddress				=	@MacAddress 
						, @InterNetIP				=	@InterNetIP 
				
				If Not Exists( SELECT 1 FROM T0050_PRIVILEGE_DETAILS PD WITH (NOLOCK)
							INNER JOIN T0000_DEFAULT_FORM DF WITH (NOLOCK) ON  DF.FORM_ID = PD.FORM_ID
							WHERE PD.PRIVILAGE_ID = @Privilege_Id AND DF.FORM_NAME = 'Lead Application' 
							AND DF.Page_Flag in ('ER','DA','EP','DE') and PD.Is_View = 1)
					BEGIN
						SET @Result = '0:You have dont have privilege.contact to Administrator.'
						return
					End
					
				SELECT @Emp_ID AS 'Emp_ID', TEM.Emp_Full_Name AS 'Emp_Full_Name',ISNULL(TEM.Emp_code,0) AS 'Emp_code',ISNULL(TEM.Alpha_Emp_Code,'') AS 'Alpha_Emp_Code'
						, @Cmp_Id AS 'Cmp_ID',@Cmp_Name AS 'Cmp_Name'
						, ISNULL(TL.Login_ID,0) AS 'Login_ID',ISNULL(TL.Login_Name,'') AS 'Login_Name'
						, ISNULL(TL.Login_Rights_ID,0) AS 'Login_Rights_ID',ISNULL(TL.Login_Alias,'') AS 'Login_Alias'
						, ISNULL(TEM.Image_Name,'') AS 'Image_Name',ISNULL(TEM.Gender,'') AS 'EmpGender'
						, ISNULL(TEM.Desig_Id,0) AS 'Desig_Id', ISNULL(TDM.Desig_Name,'') AS 'Desig_Name'
						, ISNULL(TDP.Dept_Name,'') AS 'Dept_Name', ISNULL(TBR.Branch_Name,'') AS 'Branch_Name'
						, ISNULL(@Privilege_Id,0) AS 'Privilege_ID'
						
				FROM T0080_EMP_MASTER TEM WITH (NOLOCK)
				INNER JOIN T0010_COMPANY_MASTER TCM WITH (NOLOCK) ON TEM.Cmp_ID = TCM.Cmp_Id
				INNER JOIN T0011_LOGIN TL WITH (NOLOCK) ON TEM.Emp_ID = TL.Emp_ID
				LEFT JOIN (
								SELECT s.* FROM T0095_INCREMENT s WITH (NOLOCK)
								INNER JOIN(								
										SELECT MAX(t.Increment_ID) AS 'Increment_ID',t.Emp_ID FROM T0095_INCREMENT t WITH (NOLOCK)
										INNER JOIN(
											SELECT Emp_ID,MAX(Increment_Effective_Date) AS 'Increment_Effective_Date'
											FROM T0095_INCREMENT WITH (NOLOCK)
											GROUP BY Emp_ID
										)q ON t.Increment_Effective_Date = q.Increment_Effective_Date AND q.Emp_ID = t.Emp_ID
										GROUP BY t.Emp_ID
									)I ON 	s.Increment_ID = I.Increment_ID								
							)TIC ON TEM.Emp_ID = TIC.Emp_ID
				LEFT JOIN T0040_DESIGNATION_MASTER TDM WITH (NOLOCK) ON TDM.Desig_ID = ISNULL(TIC.Desig_Id, TEM.Desig_Id)
				LEFT JOIN T0040_DEPARTMENT_MASTER TDP WITH (NOLOCK) ON TDP.Dept_Id= ISNULL(TIC.Dept_ID, TEM.Dept_ID)
				LEFT JOIN T0030_BRANCH_MASTER TBR  WITH (NOLOCK) ON TBR.Branch_ID = ISNULL(TIC.Branch_ID, TEM.Branch_ID)
				WHERE TEM.Emp_ID = @Emp_ID
				
				SET @Result = '1:Successfully logged in to Lead System'
				
			END		
	END




