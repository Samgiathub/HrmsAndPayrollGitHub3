



-- =============================================
-- Author:		<Ripal Patel>
-- ALTER date: <07-Mar-2013>
-- exec [P0090_HRMS_Appraisal_Emp_SOLAssessmentDtlGet] 1,20,1,''
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0090_HRMS_Appraisal_Emp_SOLAssessmentDtlGet]
	@SOLAssessment_Id		numeric(18,0),
	@FK_SettingId			numeric(18,0),
	@Is_Emp_Manager			numeric(18,0),
	@SearchCondition		varchar(Max)
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
    
	declare @query as varchar(MAX)
	
	set @query = '' /*01 May 2013 Ripal Patel*/
	
	set @query = 'SELECT distinct * FROM 
	(
	
  SELECT    
  (SELECT     SOL
    FROM          V0090_HRMS_Appraisal_Emp_SOLAssessmentDtl AS egrEmp
    WHERE      (Fk_SOL = MainSOL.Fk_SOL) AND (Is_Emp_Manager = 1) 
    AND (FK_SettingId = '+CAST(@FK_SettingId as varchar(10))+') ) AS SOL,
   (SELECT     Fk_SOL
    FROM          V0090_HRMS_Appraisal_Emp_SOLAssessmentDtl AS egrEmp
    WHERE      (Fk_SOL = MainSOL.Fk_SOL) AND (Is_Emp_Manager = 1) 
    AND (FK_SettingId = '+CAST(@FK_SettingId as varchar(10))+') ) AS Fk_SOL,
  (SELECT     SOLAssessmentDtl_Id
    FROM          V0090_HRMS_Appraisal_Emp_SOLAssessmentDtl AS egrEmp
    WHERE      (Fk_SOL = MainSOL.Fk_SOL) AND (Is_Emp_Manager = 1) 
    AND (FK_SettingId = '+CAST(@FK_SettingId as varchar(10))+' ) ) AS Emp_SOLAssessmentDtl_Id,
  (SELECT     FK_EmployeeId
    FROM          V0090_HRMS_Appraisal_Emp_SOLAssessmentDtl AS egrEmp
    WHERE      (Fk_SOL = MainSOL.Fk_SOL) AND (Is_Emp_Manager = 1) 
    AND (FK_SettingId = '+CAST(@FK_SettingId as varchar(10))+') ) AS EMP_EmployeeId,       
  (SELECT     IndicativeExample
    FROM          V0090_HRMS_Appraisal_Emp_SOLAssessmentDtl AS egrEmp
    WHERE      (Fk_SOL = MainSOL.Fk_SOL) AND (Is_Emp_Manager = 1) 
    AND (FK_SettingId = '+CAST(@FK_SettingId as varchar(10))+') ) AS IndicativeExample,       
  (SELECT     FK_Rating_Emp
    FROM          V0090_HRMS_Appraisal_Emp_SOLAssessmentDtl AS egrEmp
    WHERE      (Fk_SOL = MainSOL.Fk_SOL) AND (Is_Emp_Manager = 1) 
    AND (FK_SettingId = '+CAST(@FK_SettingId as varchar(10))+') ) AS FK_Rating_Emp,       
  (SELECT     ReviewSOL_Signoff
    FROM          V0090_HRMS_Appraisal_Emp_SOLAssessmentDtl AS egrEmp
    WHERE      (Fk_SOL = MainSOL.Fk_SOL) AND (Is_Emp_Manager = 1) 
    AND (FK_SettingId = '+CAST(@FK_SettingId as varchar(10))+') ) AS Emp_Review_Signoff,       
  (SELECT     ReviewSOL_SignoffDate
    FROM          V0090_HRMS_Appraisal_Emp_SOLAssessmentDtl AS egrEmp
    WHERE      (Fk_SOL = MainSOL.Fk_SOL) AND (Is_Emp_Manager = 1) 
    AND (FK_SettingId = '+CAST(@FK_SettingId as varchar(10))+') ) AS Emp_Review_SignoffDate,       
  (SELECT     Is_Emp_Manager
    FROM          V0090_HRMS_Appraisal_Emp_SOLAssessmentDtl AS egrEmp
    WHERE      (Fk_SOL = MainSOL.Fk_SOL) AND (Is_Emp_Manager = 1) 
    AND (FK_SettingId = '+CAST(@FK_SettingId as varchar(10))+') ) AS Emp_Is_Emp_Manager,          
  (SELECT     FK_SettingId
    FROM          V0090_HRMS_Appraisal_Emp_SOLAssessmentDtl AS egrEmp
    WHERE      (Fk_SOL = MainSOL.Fk_SOL) AND (Is_Emp_Manager = 1) 
    AND (FK_SettingId = '+CAST(@FK_SettingId as varchar(10))+') ) AS Emp_SettingId,
   
  (SELECT     TOP (1) SOLAssessmentDtl_Id
    FROM          V0090_HRMS_Appraisal_Emp_SOLAssessmentDtl AS egrMan
    WHERE      (Fk_SOL = MainSOL.Fk_SOL) AND (Is_Emp_Manager > 1) 
    AND ( Is_Emp_Manager = '+CAST(@Is_Emp_Manager as varchar(10))+' OR ReviewSOL_Signoff = 1 ) 
    AND (FK_SettingId = '+CAST(@FK_SettingId as varchar(10))+')
    ORDER BY Is_Emp_Manager DESC) AS Mng_SOLAssessmentDtl_Id,
    
  (SELECT     TOP (1) FK_EmployeeId
    FROM          V0090_HRMS_Appraisal_Emp_SOLAssessmentDtl AS egrMan
    WHERE      (Fk_SOL = MainSOL.Fk_SOL) AND (Is_Emp_Manager > 1) 
    AND ( Is_Emp_Manager = '+CAST(@Is_Emp_Manager as varchar(10))+' OR ReviewSOL_Signoff = 1 ) 
    AND (FK_SettingId = '+CAST(@FK_SettingId as varchar(10))+')
    ORDER BY Is_Emp_Manager DESC) AS Mng_EmployeeId,
    
   (SELECT     TOP (1) Emp_Full_Name_new
    FROM          V0090_HRMS_Appraisal_Emp_SOLAssessmentDtl AS egrMan
		left join V0080_Employee_Master on Emp_ID = FK_EmployeeId
    WHERE      (Fk_SOL = MainSOL.Fk_SOL) AND (Is_Emp_Manager > 1) 
    AND ( Is_Emp_Manager = '+CAST(@Is_Emp_Manager as varchar(10))+' OR ReviewSOL_Signoff = 1 ) 
    AND (FK_SettingId = '+CAST(@FK_SettingId as varchar(10))+')
    ORDER BY Is_Emp_Manager DESC) AS Mng_EmployeeName,
    
  (SELECT     TOP (1) DepartmentActionPlan
    FROM          V0090_HRMS_Appraisal_Emp_SOLAssessmentDtl AS egrMan
    WHERE      (Fk_SOL = MainSOL.Fk_SOL) AND (Is_Emp_Manager > 1) 
    AND ( Is_Emp_Manager = '+CAST(@Is_Emp_Manager as varchar(10))+' OR ReviewSOL_Signoff = 1 ) 
    AND (FK_SettingId = '+CAST(@FK_SettingId as varchar(10))+')
    ORDER BY Is_Emp_Manager DESC) AS DepartmentActionPlan, 
               
  (SELECT     TOP (1) FK_Rating_Sup
    FROM          V0090_HRMS_Appraisal_Emp_SOLAssessmentDtl AS egrMan
    WHERE      (Fk_SOL = MainSOL.Fk_SOL) AND (Is_Emp_Manager > 1) 
    AND ( Is_Emp_Manager = '+CAST(@Is_Emp_Manager as varchar(10))+' OR ReviewSOL_Signoff = 1 ) 
    AND (FK_SettingId = '+CAST(@FK_SettingId as varchar(10))+')
    ORDER BY Is_Emp_Manager DESC) AS FK_Rating_Sup,
    
  (SELECT     TOP (1) ReviewSOL_Signoff
    FROM          V0090_HRMS_Appraisal_Emp_SOLAssessmentDtl AS egrMan
    WHERE      (Fk_SOL = MainSOL.Fk_SOL) AND (Is_Emp_Manager > 1) 
    AND ( Is_Emp_Manager = '+CAST(@Is_Emp_Manager as varchar(10))+' OR ReviewSOL_Signoff = 1 ) 
    AND (FK_SettingId = '+CAST(@FK_SettingId as varchar(10))+')
    ORDER BY Is_Emp_Manager DESC) AS Mng_Review_Signoff,
    
  (SELECT     TOP (1) ReviewSOL_SignoffDate
    FROM          V0090_HRMS_Appraisal_Emp_SOLAssessmentDtl AS egrMan
    WHERE      (Fk_SOL = MainSOL.Fk_SOL) AND (Is_Emp_Manager > 1) 
    AND ( Is_Emp_Manager = '+CAST(@Is_Emp_Manager as varchar(10))+' OR ReviewSOL_Signoff = 1 ) 
    AND (FK_SettingId = '+CAST(@FK_SettingId as varchar(10))+')
    ORDER BY Is_Emp_Manager DESC) AS Mng_Review_SignoffDate,  
    
  (SELECT     TOP (1) Is_Emp_Manager
    FROM          V0090_HRMS_Appraisal_Emp_SOLAssessmentDtl AS egrMan
    WHERE      (Fk_SOL = MainSOL.Fk_SOL) AND (Is_Emp_Manager > 1) 
    AND ( Is_Emp_Manager = '+CAST(@Is_Emp_Manager as varchar(10))+' OR ReviewSOL_Signoff = 1 ) 
    AND (FK_SettingId = '+CAST(@FK_SettingId as varchar(10))+')
    ORDER BY Is_Emp_Manager DESC) AS Mng_Is_Emp_Manager,
    
   (SELECT     TOP (1) FK_SettingId
    FROM           V0090_HRMS_Appraisal_Emp_SOLAssessmentDtl AS egrMan
    WHERE      (Fk_SOL = MainSOL.Fk_SOL) AND (Is_Emp_Manager > 1) 
    AND ( Is_Emp_Manager = '+CAST(@Is_Emp_Manager as varchar(10))+' OR ReviewSOL_Signoff = 1 ) 
    AND (FK_SettingId = '+CAST(@FK_SettingId as varchar(10))+')
    ORDER BY Is_Emp_Manager DESC) AS Mng_SettingId
    
   FROM         V0090_HRMS_Appraisal_Emp_SOLAssessmentDtl as MainSOL
   
   where        MainSOL.Fk_SOLAssessment_Id =  '+CAST(@SOLAssessment_Id as varchar(10))+'
   
   ) as SOLReviews WHERE 1 = 1 and isnull(SOL,'''') <> '''' '
	
	exec ( @query + @SearchCondition )
	
END



