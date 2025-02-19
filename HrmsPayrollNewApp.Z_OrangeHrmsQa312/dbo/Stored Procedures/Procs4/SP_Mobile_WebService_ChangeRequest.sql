
--exec SP_Mobile_WebService_ChangeRequest 25909,120, 'G' , ''
CREATE PROCEDURE [dbo].[SP_Mobile_WebService_ChangeRequest]
	@Emp_ID numeric(18,0),
	@Cmp_ID numeric(18,0),
	@Tran_Type char(5),
	@Result varchar(100) OUTPUT 
AS	
BEGIN

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	IF @Tran_Type = 'I'
	BEGIN
				Select 'Insert'
	END
	ELSE IF @Tran_Type = 'RT'
	BEGIN
	
		select Request_id as id ,Request_type as Name from T0040_Change_Request_Master where Cmp_ID = @Cmp_ID
		and Request_type in ('Dependent','Favourite') and Flag = 0 
		order by Request_id asc	
	END
	ELSE IF @Tran_Type = 'G'
	BEGIN
		Select Request_id,Request_Type, Request_Date, Request_status, Emp_ID,Change_Reason,Alpha_Emp_Code,Emp_Full_Name,Child_Birth_Date
		From V0090_Change_Request_Application
		where cmp_id=@Cmp_ID and Emp_ID = @Emp_ID and Flag = 0 
	ENd

END


