

--<Author -- Sumit Pathak>
--<Date -- 29-Sep-2016>--
---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[Auto_Credit_COPH_Leave]
	@Cmp_ID numeric(18,0),	
	@COPH_Credit_Days numeric(18,2)=0 output
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	Declare @Type_ID numeric(18,0)
	Declare @Leave_ID numeric(18,0)
	Declare @LEave_Credit_Days numeric(18,2)
	Declare @LEAVE_NAME nvarchar(25)
	Declare @TypeID numeric(18,0)
	Declare @Alpha_Emp_Code varchar(50)
	Declare @For_Date datetime
	Declare @Increment_ID numeric(18,0)

	select	@Leave_ID = Leave_ID ,@Leave_Name  = Leave_Name 
	from	T0040_Leave_Master WITH (NOLOCK)
	where isnull(default_Short_Name,'') = 'COPH' and cmp_ID = @cmp_Id
	
	declare CurCOPH Cursor
	for
		select	 EW.For_Date,E.Alpha_Emp_Code,EW.Increment_ID,EW.EmpTypeId 
		from	 #Emp_WH EW
				 inner join T0080_Emp_Master E WITH (NOLOCK) on E.Emp_ID=EW.EMp_ID
		where E.Cmp_ID=@cmp_Id
	Open CurCOPH
		Fetch next from CurCOPH into @For_Date,@Alpha_Emp_Code,@Increment_ID,@TypeID
			while @@FETCH_STATUS=0
				Begin
					SELECT	@Leave_Credit_Days = isnull(CF_M_Days,0) FROM T0050_LEAVE_CF_MONTHLY_SETTING LCF WITH (NOLOCK) Inner join		
						(
							SELECT	 MAX(Effective_Date) as Effective_Date
							FROM	 T0050_LEAVE_CF_MONTHLY_SETTING WITH (NOLOCK)
							where Cmp_Id = @Cmp_ID and Leave_ID = @Leave_ID and CF_M_Days > 0 and type_ID = isnull(@TypeID ,type_ID)
						)   Qry on Qry.Effective_Date = LCF.Effective_Date 
					WHERE Cmp_Id = @Cmp_ID 
					and Leave_ID = @Leave_ID and type_ID = isnull(@TypeID ,type_ID) 
					and CF_M_Days > 0
							
					If ( @Leave_Credit_Days is null) or (@Leave_Credit_Days = 0)
						set @Leave_Credit_Days = 1	
							
					SET @COPH_CREDIT_DAYS  = 0;
					
					IF ISNULL(@LEAVE_CREDIT_DAYS,0) > 0							
						BEGIN
							EXEC P0095_LEAVE_CREDIT_IMPORT  @ALPHA_EMP_CODE = @Alpha_Emp_Code,@CMP_ID = @CMP_ID,@LEAVE_NAME = @LEAVE_NAME,@LEAVE_CREDIT_DAYS = @LEAVE_CREDIT_DAYS,@FOR_DATE = @For_Date,@CREDIT_TYPE = 'AUTO_COPH' 		
							SET @COPH_CREDIT_DAYS = @COPH_CREDIT_DAYS +  @LEAVE_CREDIT_DAYS  
						End
		Fetch next from CurCOPH into @For_Date,@Alpha_Emp_Code,@Increment_ID,@TypeID	
				End
	Close CurCOPH
	Deallocate CurCOPH					
	
	
		
END

