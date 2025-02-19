---10/3/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
--exec SP_Mobile_WebService_ChgAppDetail '2022-06-01','2022-06-21',120 ,25909,0,'v'
--exec SP_Mobile_WebService_ChgAppDetail '2022-06-01','2022-06-29',120 ,25909,0,'P'
CREATE PROCEDURE [dbo].[SP_Mobile_WebService_ChgAppDetail]
	@From_date Varchar(50),
	@To_date Varchar(50),
	@Cmp_ID numeric(18,0),
	@Emp_ID numeric(18,0),
	@Flag char(5),
	@Type char(5)
AS	
BEGIN

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	IF @Type = 'P'
	BEGIN
			SELECT Request_id,Request_Type, Request_Date, Request_status, Emp_ID,Change_Reason,Alpha_Emp_Code,Emp_Full_Name,Child_Birth_Date,Request_Type_id,Dependant_Relationship
			FROM V0090_Change_Request_Application 
			WHERE Cmp_ID = @Cmp_ID and Emp_ID = @Emp_ID and Flag = 0 
			and Request_status = 'Pending'
			and cast(Request_Date as date) >= @From_date and  cast(Request_Date as date) <= @To_date
			ORDER BY Request_id desc
	END
	else IF @Type = 'A'
	BEGIN
			SELECT Request_id,Request_Type, Request_Date, Request_status, Emp_ID,Change_Reason,Alpha_Emp_Code,Emp_Full_Name,Child_Birth_Date,Request_Type_id,Dependant_Relationship
			FROM V0090_Change_Request_Application 
			WHERE Cmp_ID = @Cmp_ID and Emp_ID = @Emp_ID and Flag = 0 and cast(Request_Date as date) >= @From_date and  cast(Request_Date as date) <= @To_date
			and Request_status = 'Approval'
			ORDER BY Request_id desc
	END
	else IF @Type = 'R'
	BEGIN
			SELECT Request_id,Request_Type, Request_Date, Request_status, Emp_ID,Change_Reason,Alpha_Emp_Code,Emp_Full_Name,Child_Birth_Date,Request_Type_id,Dependant_Relationship
			FROM V0090_Change_Request_Application 
			WHERE Cmp_ID = @Cmp_ID and Emp_ID = @Emp_ID and Flag = 0 and cast(Request_Date as date) >= @From_date and  cast(Request_Date as date) <= @To_date
			and Request_status = 'Reject'
			ORDER BY Request_id desc
	END
END

