




-- =============================================
-- Author:		<Mitesh>
-- ALTER date: <05-Aug-2011>
-- Description:	<It is for adding IN TIME in table "dbo.T0150_EMP_INOUT_RECORD" when any employee logs in and confirm the popup>
-- =============================================
CREATE PROCEDURE [dbo].[SP_EMP_IN_EDIT]
	@Emp_Id As Numeric,
	@CMP_ID As NUMERIC,
	@IP_Add As Varchar(50)	
AS

		SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON

BEGIN
	
	Declare @IO_Tran_ID numeric(18,0)   	
	Declare @For_Date Datetime
	Declare @In_Time Datetime 
	Declare @Out_Time Datetime
	Declare @In_Time_New Datetime 
	
	set @In_Time_New = GetDate()
	
    Set @For_Date = Convert(varchar(10),GETDATE(),120) 
		
		Select @In_Time = max(In_time),@Out_Time = max(Out_time) From dbo.T0150_emp_inout_Record WITH (NOLOCK) where Emp_ID=@Emp_ID And Cmp_id=@Cmp_ID and Convert(varchar(10),For_Date,120) = Convert(varchar(10),GETDATE(),120)
		
		if Not @In_time is null 
			begin
				If datediff(s,@In_Time,GetDate()) > = 0 and GetDate() > @Out_Time
					begin
						
						Select @IO_Tran_ID = isnull(max(IO_Tran_ID),0)+ 1 from dbo.T0150_emp_inout_Record WITH (NOLOCK)
											
						Insert Into dbo.T0150_emp_inout_Record (IO_Tran_Id,Emp_Id,Cmp_Id,For_date,In_Time,IP_Address) Values (@IO_Tran_ID,@Emp_Id,@Cmp_Id,Convert(varchar(10),GETDATE(),120),GetDate(),@IP_Add)
					end
			end
		Else
			begin
				
				Select @IO_Tran_ID = isnull(max(IO_Tran_ID),0)+ 1 from dbo.T0150_emp_inout_Record WITH (NOLOCK)
								
				Insert Into dbo.T0150_emp_inout_Record (IO_Tran_Id,Emp_Id,Cmp_Id,For_date,In_Time,IP_Address) Values (@IO_Tran_ID,@Emp_Id,@Cmp_Id,Convert(varchar(10),GETDATE(),120),GetDate(),@IP_Add)
			end
END


