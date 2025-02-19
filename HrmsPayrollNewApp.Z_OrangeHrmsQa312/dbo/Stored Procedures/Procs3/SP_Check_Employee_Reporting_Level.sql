

---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_Check_Employee_Reporting_Level] 
	-- Add the parameters for the stored procedure here
	@Emp_ID INT,
	@Is_Final_Reporting_Level TINYINT=0 OUTPUT
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	Declare @Scheme_Id As INTEGER 
	
	Declare @MaxScheme_Detail_ID AS INTEGER 
	Declare @Last_Level_Emp_ID AS INTEGER
	
	Set @MaxScheme_Detail_ID =0
	SET @Last_Level_Emp_ID=0
	
	 CREATE TABLE #tbl_Scheme
	 (
		Scheme_Detail_ID    INT,
		Scheme_ID			INT,
		Emp_ID          INT
	 )  
	CREATE NONCLUSTERED INDEX Ix_tbl_Scheme_SchemeId on #tbl_Scheme (Scheme_ID,Scheme_Detail_ID)
	
	
	Set @Scheme_Id=0
	
	
			
	IF @Emp_ID <> 0  --Need to Put Else Condition for Admin
	BEGIN
	
			SELECT @Scheme_Id=SD.Scheme_Id FROM T0050_Scheme_Detail SD	WITH (NOLOCK)	
			INNER JOIN T0040_Scheme_Master SM WITH (NOLOCK) ON SD.Scheme_Id = SM.Scheme_Id  
			WHERE SD.App_Emp_ID=@Emp_ID and Scheme_Type = 'Employee Application' 
			
			IF @Scheme_Id <> 0
			BEGIN
				INSERT INTO #tbl_Scheme
				Select SD.Scheme_Detail_Id,SD.Scheme_Id,SD.App_Emp_ID As Emp_ID
				FROM	T0050_Scheme_Detail SD WITH (NOLOCK)
					--INNER JOIN T0030_BRANCH_MASTER BM on sd.Cmp_Id = bm.Cmp_ID and (CHARINDEX('#' + CAST(BM.BRANCH_ID AS VARCHAR(10)) + '#', '#' + sd.Leave + '#') > 0)
								INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) on sd.Cmp_Id = bm.Cmp_ID and ((CHARINDEX('#' + CAST(BM.BRANCH_ID AS VARCHAR(10)) + '#', '#' + sd.Leave + '#') > 0) OR sd.Leave = '0')
					INNER JOIN T0040_Scheme_Master SM WITH (NOLOCK) ON SD.Scheme_Id = SM.Scheme_Id 
				WHERE	SM.Scheme_Type = 'Employee Application'  and SD.Scheme_Id = @Scheme_Id
				
			END
			ELSE 
				BEGIN
					INSERT INTO #tbl_Scheme
					Select SD.Scheme_Detail_Id,SD.Scheme_Id,SD.App_Emp_ID As Emp_ID
					FROM	T0050_Scheme_Detail SD WITH (NOLOCK)
						--INNER JOIN T0030_BRANCH_MASTER BM on sd.Cmp_Id = bm.Cmp_ID and (CHARINDEX('#' + CAST(BM.BRANCH_ID AS VARCHAR(10)) + '#', '#' + sd.Leave + '#') > 0)
									INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) on sd.Cmp_Id = bm.Cmp_ID and ((CHARINDEX('#' + CAST(BM.BRANCH_ID AS VARCHAR(10)) + '#', '#' + sd.Leave + '#') > 0) OR sd.Leave = '0')
						INNER JOIN T0040_Scheme_Master SM WITH (NOLOCK) ON SD.Scheme_Id = SM.Scheme_Id 
					WHERE	SM.Scheme_Type = 'Employee Application'
				END
		    
	END
	
	--select * from #tbl_Scheme
	--ELSE
	--  BEGIN
	--	    INSERT INTO #tbl_Scheme
	--		Select SD.Scheme_Id,SD.Rpt_Level,BM.BRANCH_ID as Branch_ID, SM.Scheme_Name,SD.App_Emp_ID As App_Emp_ID
	--		FROM	T0050_Scheme_Detail SD 
	--			INNER JOIN T0030_BRANCH_MASTER BM on sd.Cmp_Id = bm.Cmp_ID and (CHARINDEX('#' + CAST(BM.BRANCH_ID AS VARCHAR(10)) + '#', '#' + sd.Leave + '#') > 0)
	--			INNER JOIN T0040_Scheme_Master SM ON SD.Scheme_Id = SM.Scheme_Id 
	--	    WHERE	SM.Scheme_Type = 'Employee Application'
	--END
	
--	select * from  #tbl_Scheme  
	SELECT @MaxScheme_Detail_ID= MAX(ISNULL(Scheme_Detail_Id,0)) FROM #tbl_Scheme
	
	--Select @MaxScheme_Detail_ID As MaxScheme_Detail_ID
	
	
	SELECT @Last_Level_Emp_ID = Emp_ID FROM #tbl_Scheme WHERE Scheme_Detail_ID=@MaxScheme_Detail_ID 
				
	
	--Select @Last_Level_Emp_ID As Last_Level_Emp_ID
	
	IF @Last_Level_Emp_ID = @Emp_ID
	BEGIN
		SET  @Is_Final_Reporting_Level=1
	END

	SELECT  @Is_Final_Reporting_Level
         
END


