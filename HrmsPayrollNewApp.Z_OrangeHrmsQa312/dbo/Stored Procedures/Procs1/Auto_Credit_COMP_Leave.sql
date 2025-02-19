


---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[Auto_Credit_COMP_Leave]
	@Cmp_ID numeric(18,0),	
	@COMP_Credit_Days numeric(18,2)=0 output
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	Declare @Leave_ID numeric(18,0)
	Declare @LEAVE_NAME nvarchar(25)
	Declare @Alpha_Emp_Code varchar(50)
	Declare @For_Date datetime
	Declare @Increment_ID numeric(18,0)

	select	@Leave_ID = Leave_ID ,@Leave_Name  = Leave_Name 
	from	T0040_Leave_Master WITH (NOLOCK)
	where isnull(default_Short_Name,'') = 'COMP' and cmp_ID = @cmp_Id
	
	Declare CurCOMP Cursor
	for
		select	 EW.For_Date,E.Alpha_Emp_Code
		from	 #Emp_WH EW
				 inner join T0080_Emp_Master E WITH (NOLOCK) on E.Emp_ID=EW.EMp_ID
		where E.Cmp_ID=@cmp_Id
	Open CurCOMP
		Fetch next from CurCOMP into @For_Date,@Alpha_Emp_Code
			while @@FETCH_STATUS=0
				Begin		
						SET @COMP_Credit_Days  = 0;	
						EXEC P0095_LEAVE_CREDIT_IMPORT  @ALPHA_EMP_CODE = @Alpha_Emp_Code,@CMP_ID = @CMP_ID,@LEAVE_NAME = @LEAVE_NAME,@LEAVE_CREDIT_DAYS = 1,@FOR_DATE = @For_Date,@CREDIT_TYPE = 'AUTO_COMP' 		
						SET @COMP_Credit_Days = @COMP_Credit_Days +  1  
					Fetch next from CurCOMP into @For_Date,@Alpha_Emp_Code	
				End
	Close CurCOMP
	Deallocate CurCOMP

END

