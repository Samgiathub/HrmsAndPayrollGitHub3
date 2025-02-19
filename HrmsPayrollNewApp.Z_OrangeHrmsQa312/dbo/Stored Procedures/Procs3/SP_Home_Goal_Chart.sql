-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_Home_Goal_Chart]
	-- Add the parameters for the stored procedure here
	@Cmp_ID int,
	@Emp_ID int
AS

		SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON

BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	

Create Table T1(Id int, Emp_Id varchar(50),Initiate_Status int,Initiate varchar(50),levels int,Perchantage int)
Insert into T1 
Select KPA_InitiateId,Emp_Id,Initiate_Status,CASE WHEN Initiate_Status = 4 THEN 'Not Submitted' WHEN Initiate_Status = 0 THEN 'Draft' WHEN Initiate_Status = 1 THEN 'Approved' WHEN Initiate_Status = 2 THEN 'Submitted by Appraisee' WHEN
                       Initiate_Status = 3 THEN 'Sent For Employee Review' WHEN Initiate_Status = 5 THEN 'Approved by Manager' WHEN Initiate_Status = 6 THEN 'Sent For Manager Review' WHEN Initiate_Status = 7 THEN
                       'Approved By HOD' WHEN Initiate_Status = 8 THEN 'Sent For HOD Review' END AS InitiateStatus,
                       CASE WHEN GH_Id IS NOT NULL THEN '4' WHEN Hod_Id IS NOT NULL THEN '3' Else '2'  END AS levels,
                       CASE WHEN Initiate_Status =1 THEN '100' WHEN  Initiate_Status = 4 and GH_Id IS NOT NULL  THEN '25'  WHEN  Initiate_Status = 4 and Hod_Id IS NOT NULL  THEN '33' Else '50'  END AS Perchantage
                        from T0055_Hrms_Initiate_KPASetting WITH (NOLOCK) WHERE Emp_Id = @Emp_ID AND Cmp_Id = @Cmp_ID
Union 
Select KPA_InitiateId,Emp_Id,Initiate_Status,CASE WHEN Initiate_Status = 4 THEN 'Not Submitted' WHEN Initiate_Status = 0 THEN 'Draft' WHEN Initiate_Status = 1 THEN 'Approved' WHEN Initiate_Status = 2 THEN 'Submitted by Appraisee' WHEN
                       Initiate_Status = 3 THEN 'Sent For Employee Review' WHEN Initiate_Status = 5 THEN 'Approved by Manager' WHEN Initiate_Status = 6 THEN 'Sent For Manager Review' WHEN Initiate_Status = 7 THEN
                       'Approved By HOD' WHEN Initiate_Status = 8 THEN 'Sent For HOD Review' END AS InitiateStatus,
                       CASE WHEN GH_Id IS NOT NULL THEN '4' WHEN Hod_Id IS NOT NULL THEN '3' Else '2'  END AS levels,
                       CASE WHEN Initiate_Status =1 THEN '100' WHEN  Initiate_Status = 4 and GH_Id IS NOT NULL  THEN '25'  WHEN  Initiate_Status = 4 and Hod_Id IS NOT NULL  THEN '33' Else '50'  END AS Perchantage
                              from T0055_Hrms_Initiate_KPASetting WITH (NOLOCK) WHERE Emp_Id = @Emp_ID AND Cmp_Id = @Cmp_ID
;WITH Num1 (Initiate_Status) AS (SELECT 1 UNION ALL SELECT 1),
Num2 (n) AS (SELECT 1 FROM Num1 AS X, Num1 AS Y),
Num3 (n) AS (SELECT 1 FROM Num2 AS X, Num2 AS Y),
Num4 (n) AS (SELECT 1 FROM Num3 AS X, Num3 AS Y),
Nums (n) AS (SELECT ROW_NUMBER() OVER(ORDER BY n) FROM Num4)
Select A.* From T1 A
Cross apply (Select * From NUMS Where n<A.levels +1)A1
Order by Id
END
Drop table T1
