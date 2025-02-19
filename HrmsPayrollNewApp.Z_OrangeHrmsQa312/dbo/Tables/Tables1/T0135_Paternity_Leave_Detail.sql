CREATE TABLE [dbo].[T0135_Paternity_Leave_Detail] (
    [Tran_Id]           NUMERIC (18)    IDENTITY (1, 1) NOT NULL,
    [Cmp_Id]            NUMERIC (18)    NOT NULL,
    [Emp_Id]            NUMERIC (18)    NOT NULL,
    [Leave_Id]          NUMERIC (18)    NOT NULL,
    [For_Date]          DATETIME        NOT NULL,
    [Paternity_Balance] NUMERIC (18, 2) CONSTRAINT [DF_T0135_Paternity_Leave_Detail_Paternity_Balance] DEFAULT ((0)) NOT NULL,
    [Validity_Days]     NUMERIC (18)    CONSTRAINT [DF_T0135_Paternity_Leave_Detail_Validity_Days] DEFAULT ((0)) NOT NULL,
    [Laps_Status]       VARCHAR (50)    NOT NULL,
    [System_Date]       DATETIME        NOT NULL
);


GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE TRIGGER [DBO].[Tri_T0135_Paternity_Leave_Detail_Update]
   ON  [dbo].[T0135_Paternity_Leave_Detail]
   For Update,Delete
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	declare @Emp_Id numeric(18,0)
	declare @Leave_ID numeric(18,0)
	declare @For_date datetime
	declare @Cmp_Id numeric(18,0)
	
	IF UPDATE (Laps_Status) 
	begin
		select  @Cmp_Id = Cmp_Id, @Emp_Id = Emp_Id,@Leave_ID = Leave_ID, @For_date = For_Date
		from inserted ins 
		
		declare @Tran_MaxDate datetime
		if exists (select * from T0040_LEAVE_MASTER where Cmp_ID = @Cmp_Id and Leave_ID=@Leave_ID and Leave_Type = 'Paternity Leave')
		BEGIN
			
			SELECT TOP 1 @TRAN_MAXDATE = FOR_DATE 
			FROM T0140_LEAVE_TRANSACTION 
			WHERE CMP_ID=@CMP_ID AND EMP_ID=@EMP_ID AND LEAVE_ID = @LEAVE_ID
			and For_Date >= @For_date
			ORDER BY FOR_DATE DESC
			
			select @TRAN_MAXDATE
			UPDATE LT SET LT.CF_LAPS_DAYS = LT.LEAVE_CLOSING, LEAVE_CLOSING = 0  			
			FROM T0140_LEAVE_TRANSACTION LT 
			WHERE LT.CMP_ID= @CMP_ID AND LT.LEAVE_ID = @LEAVE_ID 
					AND LT.FOR_DATE = @TRAN_MAXDATE
					AND LT.EMP_ID = @EMP_ID
			
		END
	
	END
	
	--IF delete (Leave_Id)
	--BEGIN
	--	select  @Cmp_Id = Cmp_Id, @Emp_Id = Emp_Id,@Leave_ID = Leave_ID, @For_date = For_Date
	--	from inserted ins 
		
	--	select * FROM T0140_LEAVE_TRANSACTION where Cmp_id=@Cmp_Id and leave_id=@Leave_Id 
	--end	
	
END


