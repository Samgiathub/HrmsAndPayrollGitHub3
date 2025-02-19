



-- =============================================
-- Author:		<Ripal Patel>
-- ALTER date: <04-Mar-2013>
-- exec [P0090_HRMS_Appraisal_Emp_PerfSummReviewGet] 1,67,4,''
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0090_HRMS_Appraisal_Emp_PerfSummReviewGet]
	@PS_Id		numeric(18,0),
	@FK_SettingId		numeric(18,0),
	@Is_Emp_Manager		numeric(18,0),
	@SearchCondition as varchar(Max)
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
    
	declare @query as varchar(MAX)
	
	set @query = '' /*01 may 2013 By Ripal Patel*/
	
	set @query = 'SELECT * FROM (
		 SELECT    PS_Id,PS_CmpId,FK_EmployeeId,FK_SupervisorId,PS_Year,PS_CreatedBy,PS_CreatedDate,PS_ModifyBy,PS_ModifyDate,
          (SELECT     PSReview_Id
            FROM          T0090_HRMS_Appraisal_Emp_PerfSummReview AS egrEmp WITH (NOLOCK)
            WHERE      (FK_PSId = MainPS.PS_Id) AND (Is_Emp_Manager = 1) 
            AND (FK_SettingId = '+CAST(@FK_SettingId as varchar(10))+') ) AS Emp_Review_ID,
          (SELECT     FK_EmployeeId
            FROM          T0090_HRMS_Appraisal_Emp_PerfSummReview AS egrEmp WITH (NOLOCK) 
            WHERE      (FK_PSId = MainPS.PS_Id) AND (Is_Emp_Manager = 1) 
            AND (FK_SettingId = '+CAST(@FK_SettingId as varchar(10))+') ) AS EMP_EmployeeId,       
          (SELECT     PS_Comment
            FROM          T0090_HRMS_Appraisal_Emp_PerfSummReview AS egrEmp WITH (NOLOCK)
            WHERE      (FK_PSId = MainPS.PS_Id) AND (Is_Emp_Manager = 1) 
            AND (FK_SettingId = '+CAST(@FK_SettingId as varchar(10))+') ) AS Emp_PS_Comment,       
          (SELECT     CP_Comment
            FROM          T0090_HRMS_Appraisal_Emp_PerfSummReview AS egrEmp WITH (NOLOCK)
            WHERE      (FK_PSId = MainPS.PS_Id) AND (Is_Emp_Manager = 1) 
            AND (FK_SettingId = '+CAST(@FK_SettingId as varchar(10))+') ) AS Emp_CP_Comment,       
          (SELECT     FK_RatingId
            FROM          T0090_HRMS_Appraisal_Emp_PerfSummReview AS egrEmp WITH (NOLOCK)
            WHERE      (FK_PSId = MainPS.PS_Id) AND (Is_Emp_Manager = 1) 
            AND (FK_SettingId = '+CAST(@FK_SettingId as varchar(10))+') ) AS Emp_FK_Rating,       
          (SELECT     PSReview_Signoff
            FROM          T0090_HRMS_Appraisal_Emp_PerfSummReview AS egrEmp WITH (NOLOCK)
            WHERE      (FK_PSId = MainPS.PS_Id) AND (Is_Emp_Manager = 1) 
            AND (FK_SettingId = '+CAST(@FK_SettingId as varchar(10))+') ) AS Emp_Review_Signoff,       
          (SELECT     PSReview_SignoffDate
            FROM          T0090_HRMS_Appraisal_Emp_PerfSummReview AS egrEmp WITH (NOLOCK)
            WHERE      (FK_PSId = MainPS.PS_Id) AND (Is_Emp_Manager = 1) 
            AND (FK_SettingId = '+CAST(@FK_SettingId as varchar(10))+') ) AS Emp_Review_SignoffDate,
          (SELECT     Is_Emp_Manager
            FROM          T0090_HRMS_Appraisal_Emp_PerfSummReview AS egrEmp WITH (NOLOCK)
            WHERE      (FK_PSId = MainPS.PS_Id) AND (Is_Emp_Manager = 1) 
            AND (FK_SettingId = '+CAST(@FK_SettingId as varchar(10))+') ) AS Emp_Is_Emp_Manager,  
                    
          (SELECT     TOP (1) PSReview_Id
            FROM          T0090_HRMS_Appraisal_Emp_PerfSummReview AS egrMan WITH (NOLOCK)
            WHERE      (FK_PSId = MainPS.PS_Id) AND (Is_Emp_Manager > 1)
            AND ( Is_Emp_Manager = '+CAST(@Is_Emp_Manager as varchar(10))+' OR PSReview_Signoff = 1 ) 
            AND (FK_SettingId = '+CAST(@FK_SettingId as varchar(10))+')
            ORDER BY Is_Emp_Manager DESC) AS Mng_Review_ID,
            
          (SELECT     TOP (1) FK_EmployeeId
            FROM          T0090_HRMS_Appraisal_Emp_PerfSummReview AS egrMan WITH (NOLOCK)
            WHERE      (FK_PSId = MainPS.PS_Id) AND (Is_Emp_Manager > 1) 
            AND ( Is_Emp_Manager = '+CAST(@Is_Emp_Manager as varchar(10))+' OR PSReview_Signoff = 1 )
            AND (FK_SettingId = '+CAST(@FK_SettingId as varchar(10))+')
            ORDER BY Is_Emp_Manager DESC) AS Mng_EmployeeId,
    
           (SELECT     TOP (1) Emp_Full_Name_new
            FROM          T0090_HRMS_Appraisal_Emp_PerfSummReview AS egrMan WITH (NOLOCK)
				left join V0080_Employee_Master on Emp_ID = FK_EmployeeId
            WHERE      (FK_PSId = MainPS.PS_Id) AND (Is_Emp_Manager > 1) 
            AND ( Is_Emp_Manager = '+CAST(@Is_Emp_Manager as varchar(10))+' OR PSReview_Signoff = 1 )
            AND (FK_SettingId = '+CAST(@FK_SettingId as varchar(10))+')
            ORDER BY Is_Emp_Manager DESC) AS Mng_EmployeeName,
            
          (SELECT     TOP (1) PS_Comment
            FROM          T0090_HRMS_Appraisal_Emp_PerfSummReview AS egrMan WITH (NOLOCK)
            WHERE      (FK_PSId = MainPS.PS_Id) AND (Is_Emp_Manager > 1) 
            AND ( Is_Emp_Manager = '+CAST(@Is_Emp_Manager as varchar(10))+' OR PSReview_Signoff = 1 )
            AND (FK_SettingId = '+CAST(@FK_SettingId as varchar(10))+')
            ORDER BY Is_Emp_Manager DESC) AS Mng_PS_Comment,
                        
          (SELECT     TOP (1) CP_Comment
            FROM          T0090_HRMS_Appraisal_Emp_PerfSummReview AS egrMan WITH (NOLOCK)
            WHERE      (FK_PSId = MainPS.PS_Id) AND (Is_Emp_Manager > 1) 
            AND ( Is_Emp_Manager = '+CAST(@Is_Emp_Manager as varchar(10))+' OR PSReview_Signoff = 1 )
            AND (FK_SettingId = '+CAST(@FK_SettingId as varchar(10))+')
            ORDER BY Is_Emp_Manager DESC) AS Mng_CP_Comment,
            
          (SELECT     TOP (1) FK_RatingId
            FROM          T0090_HRMS_Appraisal_Emp_PerfSummReview AS egrMan WITH (NOLOCK)
            WHERE      (FK_PSId = MainPS.PS_Id) AND (Is_Emp_Manager > 1) 
            AND ( Is_Emp_Manager = '+CAST(@Is_Emp_Manager as varchar(10))+' OR PSReview_Signoff = 1 )
            AND (FK_SettingId = '+CAST(@FK_SettingId as varchar(10))+')
            ORDER BY Is_Emp_Manager DESC) AS Mng_FK_Rating,
            
          (SELECT     TOP (1) PSReview_Signoff
            FROM          T0090_HRMS_Appraisal_Emp_PerfSummReview AS egrMan WITH (NOLOCK)
            WHERE      (FK_PSId = MainPS.PS_Id) AND (Is_Emp_Manager > 1) 
            AND ( Is_Emp_Manager = '+CAST(@Is_Emp_Manager as varchar(10))+' OR PSReview_Signoff = 1 )
            AND (FK_SettingId = '+CAST(@FK_SettingId as varchar(10))+')
            ORDER BY Is_Emp_Manager DESC) AS Mng_Review_Signoff,
            
          (SELECT     TOP (1) PSReview_SignoffDate
            FROM          T0090_HRMS_Appraisal_Emp_PerfSummReview AS egrMan WITH (NOLOCK)
            WHERE      (FK_PSId = MainPS.PS_Id) AND (Is_Emp_Manager > 1) 
            AND ( Is_Emp_Manager = '+CAST(@Is_Emp_Manager as varchar(10))+' OR PSReview_Signoff = 1 )
            AND (FK_SettingId = '+CAST(@FK_SettingId as varchar(10))+')
            ORDER BY Is_Emp_Manager DESC) AS Mng_Review_SignoffDate,
            
          (SELECT     TOP (1) Is_Emp_Manager
            FROM          T0090_HRMS_Appraisal_Emp_PerfSummReview AS egrMan WITH (NOLOCK)
            WHERE      (FK_PSId = MainPS.PS_Id) AND (Is_Emp_Manager > 1) 
            AND ( Is_Emp_Manager = '+CAST(@Is_Emp_Manager as varchar(10))+' OR PSReview_Signoff = 1 )
            AND (FK_SettingId = '+CAST(@FK_SettingId as varchar(10))+')
            ORDER BY Is_Emp_Manager DESC) AS Mng_Is_Emp_Manager
            
	       FROM         T0090_HRMS_Appraisal_Emp_PerformanceSummary as MainPS WITH (NOLOCK)
	       where        MainPS.PS_Id = '+CAST(@PS_Id as varchar(10))+'
	       ) as PSReviews WHERE 1 = 1'
	       
	       print @query
	       exec ( @query + @SearchCondition )
	       
END



