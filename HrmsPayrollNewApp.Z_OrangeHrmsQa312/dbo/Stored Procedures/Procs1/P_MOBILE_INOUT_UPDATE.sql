

CREATE PROCEDURE [dbo].[P_MOBILE_INOUT_UPDATE]
	@Cmp_Id  numeric(18,0),
	@IO_Tran_DetailsID numeric(18,0),
	@Emp_ID numeric(18,0),
    @Approval_Status numeric(18,0),
    @Approval_by numeric(18,0),
    --@Approval_date datetime,
    @Approval_From_Mobile numeric(18,0),
	@ManagerComment varchar(255)
AS
BEGIN
	Set Nocount on 
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ARITHABORT ON 
	
	--declare @IO_Datetime as datetime
	--select @IO_Datetime=IO_Datetime from T9999_MOBILE_INOUT_DETAIL where IO_Tran_DetailsID=@IO_Tran_DetailsID	
	--IF EXISTS (SELECT 1 FROM T0200_MONTHLY_SALARY WHERE MONTH(Month_End_Date) = month(@IO_Datetime) AND YEAR(Month_End_Date) = year(@IO_Datetime) and Emp_ID = @Emp_id)
	--	BEGIN
	--		Raiserror('Mobile In-Out can''t be Approved Reference Exist In Salary',16,2)
	--		return -1
		--END
											
	UPDATE T9999_MOBILE_INOUT_DETAIL
	SET Approval_Status=@Approval_Status,Approval_by=@Approval_by,
		Approval_date=GETDATE(),Approval_From_Mobile=@Approval_From_Mobile,ManagerComment=@ManagerComment
	WHERE Emp_ID=@Emp_ID AND IO_Tran_DetailsID=@IO_Tran_DetailsID AND Cmp_ID=@Cmp_Id
	
END
