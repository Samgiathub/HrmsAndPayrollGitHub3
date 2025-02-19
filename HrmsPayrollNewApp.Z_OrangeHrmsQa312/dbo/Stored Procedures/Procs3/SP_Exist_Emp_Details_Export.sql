

-- =============================================
-- Author:		Nilesh Patel
-- Create date: 27/02/2016
-- Description:	get Exist Employee Details with Status
---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[SP_Exist_Emp_Details_Export]
	@Cmp_ID Numeric(18,0)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

    SELECT ROW_NUMBER() OVER(ORDER BY EEA.Emp_ID) as Sr_No,'="' + EM.Alpha_Emp_Code + '"' as Alpha_Emp_Code,EM.Emp_Full_Name as 'Emp Name',DM.Desig_Name as Designation,
    Replace(CONVERT(varchar(15),EM.Date_Of_Join,106),' ','-')  As 'Date of Join',
    Replace(CONVERT(varchar(15),EEA.resignation_date,106),' ','-')  As 'Date of Resignation',
    Replace(CONVERT(varchar(15),EEA.last_date,106),' ','-')  AS 'Date of Leaving',
	CASE When EM.IS_Emp_FNF = 1 THEN 'Y' ELSE 'N' END As 'Status of FNF',
	(Case When EEA.reason = 1 THEN 'Career Growth' WHEN EEA.reason = 2 THEN 'Change in Career Path' WHEN EEA.reason = 3 THEN 'Further Education' WHEN EEA.reason = 4 THEN 'Re-Location' WHEN EEA.reason = 5 THEN 'Health Reason' WHEN EEA.reason = 6 THEN 'Personal Reason' WHEN EEA.reason = 7 THEN 'Others' END) As 'Reason',
	(Case When EEA.status = 'A' THEN 'Approve' WHEN EEA.status = 'P' THEN 'In Progress' WHEN EEA.status = 'H' THEN 'Pending' WHEN EEA.status = 'R' THEN 'Reject' END) as Status
	,Qry_1.CTC as 'CTC(Per Month)'
	,'' As Remarks
	FROM T0200_Emp_EXITAPPLICATION EEA WITH (NOLOCK) INNER JOIN  T0080_EMP_MASTER EM WITH (NOLOCK)
	On EM.Emp_ID = EEA.emp_id
	LEFT JOIN T0040_DESIGNATION_MASTER DM WITH (NOLOCK) On EEA.Desig_Id = DM.Desig_ID 
	INNER JOIN(
	SELECT I.Emp_ID,I.CTC FROM T0095_INCREMENT I WITH (NOLOCK)
	INNER JOIN(SELECT MAX(Increment_Effective_Date)as EffectiveDate,Emp_ID From T0095_INCREMENT WITH (NOLOCK) Where Increment_Effective_Date < GETDATE()and Cmp_ID = @Cmp_ID
		GROUP By Emp_ID) as Qry
		ON Qry.EffectiveDate = I.Increment_Effective_Date and Qry.Emp_ID = I.Emp_ID
	) as Qry_1
	ON Qry_1.Emp_ID = EM.Emp_ID 
	where EEA.cmp_id = @Cmp_ID
	
	Union 
	
	SELECT Count(EEA.Emp_ID) + 1 as Sr_No,'' as Alpha_Emp_Code,'' as 'Emp Name','Total' as Designation,
    ''  As 'Date of Join',
    ''  As 'Date of Resignation',
    ''  AS 'Date of Leaving',
	'' As 'Status of FNF',
	'' As 'Reason',
	'' as Status,
	SUM(Qry_1.CTC) as 'CTC(Per Month)'
	,'' As Remarks
	FROM T0200_Emp_EXITAPPLICATION EEA WITH (NOLOCK) INNER JOIN  T0080_EMP_MASTER EM WITH (NOLOCK)
	On EM.Emp_ID = EEA.emp_id
	LEFT JOIN T0040_DESIGNATION_MASTER DM WITH (NOLOCK) On EEA.Desig_Id = DM.Desig_ID 
	INNER JOIN(
	SELECT I.Emp_ID,I.CTC FROM T0095_INCREMENT I WITH (NOLOCK)
	INNER JOIN(SELECT MAX(Increment_Effective_Date)as EffectiveDate,Emp_ID From T0095_INCREMENT WITH (NOLOCK) Where Increment_Effective_Date < GETDATE()and Cmp_ID = @Cmp_ID
		GROUP By Emp_ID) as Qry
		ON Qry.EffectiveDate = I.Increment_Effective_Date and Qry.Emp_ID = I.Emp_ID
	) as Qry_1
	ON Qry_1.Emp_ID = EM.Emp_ID 
	where EEA.cmp_id = @Cmp_ID
	
END

