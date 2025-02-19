



-- =============================================
-- Author:		<Ripal Patel>
-- ALTER date: <28-Feb-2013>
--  EXEC P0090_HRMS_Appraisal_Emp_GoalReviewGet 1,66,1,' AND Emp_Signoff_Review = 1 '
--  EXEC P0090_HRMS_Appraisal_Emp_GoalReviewGet 1,27,1,''
---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0090_HRMS_Appraisal_Emp_GoalReviewGet]
	@FK_GoalId	  as numeric(18,0),
	@FK_SettingId as numeric(18,0),
	@Is_Emp_Manager as numeric(18,0),
	@SearchCondition as varchar(1000)
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
    

		declare @query as varchar(MAX)
		
		set @query = '' /* 01 May 2013 By Ripal */
		
		set @query = ' SELECT * FROM (
		  SELECT     GoalDescription_Id, FK_GoalId, GoalDescription_CmpId, GoalDescription, SuccessCriteria, FK_GoalType, AbovePar, AtPar, BelowPar, Employee_Comment, 
                      Supervisor_Comment, FK_Rating, FK_EmployeeId, FK_SupervisorId, GoalDescription_Year, GoalDescription_CreatedBy, GoalDescription_CreatedDate, 
                      GoalDescription_ModifyBy, GoalDescription_ModifyDate,
          (SELECT     ReviewGoal_Id
            FROM          T0090_HRMS_Appraisal_Emp_GoalReview AS egrEmp WITH (NOLOCK)
            WHERE      (FK_GoalDescriptionId = appDes.GoalDescription_Id) AND (Is_Emp_Manager = 1) 
            AND (FK_SettingId = '+CAST(@FK_SettingId as varchar(10))+') ) AS Emp_Review_ID,
          (SELECT     Comment
            FROM          T0090_HRMS_Appraisal_Emp_GoalReview AS egrEmp WITH (NOLOCK)
            WHERE      (FK_GoalDescriptionId = appDes.GoalDescription_Id) AND (Is_Emp_Manager = 1) 
            AND (FK_SettingId = '+CAST(@FK_SettingId as varchar(10))+')) AS Emp_Comment_Review,
          (SELECT     FK_EmployeeId
            FROM          T0090_HRMS_Appraisal_Emp_GoalReview AS egrEmp WITH (NOLOCK)
            WHERE      (FK_GoalDescriptionId = appDes.GoalDescription_Id) AND (Is_Emp_Manager = 1) 
            AND (FK_SettingId = '+CAST(@FK_SettingId as varchar(10))+')) AS Emp_ID_Review,
          (SELECT     FK_SettingId
            FROM          T0090_HRMS_Appraisal_Emp_GoalReview AS egrEmp WITH (NOLOCK)
            WHERE      (FK_GoalDescriptionId = appDes.GoalDescription_Id) AND (Is_Emp_Manager = 1) 
            AND (FK_SettingId = '+CAST(@FK_SettingId as varchar(10))+')) AS Emp_SettingId_Review,
          (SELECT     ReviewGoal_Signoff
            FROM          T0090_HRMS_Appraisal_Emp_GoalReview AS egrEmp WITH (NOLOCK)
            WHERE      (FK_GoalDescriptionId = appDes.GoalDescription_Id) AND (Is_Emp_Manager = 1) 
            AND (FK_SettingId = '+CAST(@FK_SettingId as varchar(10))+')) AS Emp_Signoff_Review,
          (SELECT     ReviewGoal_SignoffDate
            FROM          T0090_HRMS_Appraisal_Emp_GoalReview AS egrEmp WITH (NOLOCK)
            WHERE      (FK_GoalDescriptionId = appDes.GoalDescription_Id) AND (Is_Emp_Manager = 1) 
            AND (FK_SettingId = '+CAST(@FK_SettingId as varchar(10))+')) AS Emp_SignoffDate_Review,
            
          (SELECT     TOP (1) ReviewGoal_Id
            FROM          T0090_HRMS_Appraisal_Emp_GoalReview AS egrMan WITH (NOLOCK)
            WHERE      (FK_GoalDescriptionId = appDes.GoalDescription_Id) AND (Is_Emp_Manager > 1) 
            AND ( Is_Emp_Manager = '+CAST(@Is_Emp_Manager as varchar(10))+' OR ReviewGoal_Signoff = 1 )
            AND (FK_SettingId = '+CAST(@FK_SettingId as varchar(10))+')
            ORDER BY Is_Emp_Manager DESC) AS Mng_Review_ID,
            
          (SELECT     TOP (1) Comment
            FROM          T0090_HRMS_Appraisal_Emp_GoalReview AS egrMan WITH (NOLOCK)
            WHERE      (FK_GoalDescriptionId = appDes.GoalDescription_Id) AND (Is_Emp_Manager > 1)
            AND ( Is_Emp_Manager = '+CAST(@Is_Emp_Manager as varchar(10))+' OR ReviewGoal_Signoff = 1 ) 
            AND (FK_SettingId = '+CAST(@FK_SettingId as varchar(10))+')
            ORDER BY Is_Emp_Manager DESC) AS Mng_Comment_Review,
            
          (SELECT     TOP (1) FK_Rating
            FROM          T0090_HRMS_Appraisal_Emp_GoalReview AS egrMan WITH (NOLOCK)
            WHERE      (FK_GoalDescriptionId = appDes.GoalDescription_Id) AND (Is_Emp_Manager > 1) 
            AND ( Is_Emp_Manager = '+CAST(@Is_Emp_Manager as varchar(10))+' OR ReviewGoal_Signoff = 1 )
            AND (FK_SettingId = '+CAST(@FK_SettingId as varchar(10))+')
            ORDER BY Is_Emp_Manager DESC) AS Mng_Rating_Review,
            
          (SELECT     TOP (1) FK_EmployeeId
            FROM          T0090_HRMS_Appraisal_Emp_GoalReview AS egrMan WITH (NOLOCK)
            WHERE      (FK_GoalDescriptionId = appDes.GoalDescription_Id) AND (Is_Emp_Manager > 1) 
            AND ( Is_Emp_Manager = '+CAST(@Is_Emp_Manager as varchar(10))+' OR ReviewGoal_Signoff = 1 )
            AND (FK_SettingId = '+CAST(@FK_SettingId as varchar(10))+')
            ORDER BY Is_Emp_Manager DESC) AS Mng_EmployeeId_Review,
            
           (SELECT     TOP (1) Emp_Full_Name_new
            FROM          T0090_HRMS_Appraisal_Emp_GoalReview AS egrMan WITH (NOLOCK)
				left join V0080_Employee_Master on Emp_ID = FK_EmployeeId 
            WHERE      (FK_GoalDescriptionId = appDes.GoalDescription_Id) AND (Is_Emp_Manager > 1) 
            AND ( Is_Emp_Manager = '+CAST(@Is_Emp_Manager as varchar(10))+' OR ReviewGoal_Signoff = 1 )
            AND (FK_SettingId = '+CAST(@FK_SettingId as varchar(10))+')
            ORDER BY Is_Emp_Manager DESC) AS Mng_EmployeeName,
            
          (SELECT     TOP (1) FK_SettingId
            FROM          T0090_HRMS_Appraisal_Emp_GoalReview AS egrMan WITH (NOLOCK)
            WHERE      (FK_GoalDescriptionId = appDes.GoalDescription_Id) AND (Is_Emp_Manager > 1) 
            AND ( Is_Emp_Manager = '+CAST(@Is_Emp_Manager as varchar(10))+' OR ReviewGoal_Signoff = 1 )
            AND (FK_SettingId = '+CAST(@FK_SettingId as varchar(10))+')
            ORDER BY Is_Emp_Manager DESC) AS Mng_SettingId_Review,
            
          (SELECT     TOP (1) ReviewGoal_Signoff
            FROM          T0090_HRMS_Appraisal_Emp_GoalReview AS egrMan WITH (NOLOCK)
            WHERE      (FK_GoalDescriptionId = appDes.GoalDescription_Id) AND (Is_Emp_Manager > 1) 
            AND ( Is_Emp_Manager = '+CAST(@Is_Emp_Manager as varchar(10))+' OR ReviewGoal_Signoff = 1 )
            AND (FK_SettingId = '+CAST(@FK_SettingId as varchar(10))+')
            ORDER BY Is_Emp_Manager DESC) AS Mng_Signoff_Review,
            
           (SELECT     TOP (1) ReviewGoal_SignoffDate
            FROM          dbo.T0090_HRMS_Appraisal_Emp_GoalReview AS egrMan WITH (NOLOCK)
            WHERE      (FK_GoalDescriptionId = appDes.GoalDescription_Id) AND (Is_Emp_Manager > 1) 
            AND ( Is_Emp_Manager = '+CAST(@Is_Emp_Manager as varchar(10))+' OR ReviewGoal_Signoff = 1 )
            AND (FK_SettingId = '+CAST(@FK_SettingId as varchar(10))+')
            ORDER BY Is_Emp_Manager DESC) AS Mng_SignoffDate_Review,
            
          (SELECT     TOP (1) Is_Emp_Manager
            FROM          dbo.T0090_HRMS_Appraisal_Emp_GoalReview AS egrMan WITH (NOLOCK)
            WHERE      (FK_GoalDescriptionId = appDes.GoalDescription_Id) AND (Is_Emp_Manager > 1) 
            AND ( Is_Emp_Manager = '+CAST(@Is_Emp_Manager as varchar(10))+' OR ReviewGoal_Signoff = 1 )
            AND (FK_SettingId = '+CAST(@FK_SettingId as varchar(10))+')
            ORDER BY Is_Emp_Manager DESC) AS Is_Emp_Manager
            
	       FROM         T0090_HRMS_Appraisal_Emp_GoalDescription AS appDes WITH (NOLOCK)
	       where        appDes.FK_GoalId = '+CAST(@FK_GoalId as varchar(10)) + ' 
	       
	       ) as GoalReviews WHERE 1 = 1 '
	       
	       print @query
	       exec ( @query + @SearchCondition )
	       
END



