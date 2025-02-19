



---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0100_BUG_REPORT]
	@Bug_ID				numeric(18, 0) OUTPUT,
	@Bug_Type			varchar(20),		
	@Bug_Description	varchar(6000), 
	@Bug_Shanp_Short	varchar(50),	
	@Bug_Code           varchar(30),
	@Bug_Severity		varchar(10), 
	@Bug_Priority		varchar(10), 
	@Bug_Reported_By	varchar(100), 
	@Bug_Reported_On	Datetime , 
	@Bug_Assigned_On	varchar(100), 
	@Bug_Exp_Fix_Date	Datetime = null, 
	@Bug_Fixed_By		varchar(100), 
	@Bug_Fixed_On		Datetime	= null, 
	@Bug_Status			varchar(20), 
	@Bug_Comment		varchar(1000),
	@Tran_Type			char(1)                     	
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	if isnull(@Bug_Exp_Fix_Date,'') =''
		set @Bug_Exp_Fix_Date = null
		
	if Isnull(@Bug_Fixed_On,'') = ''
		set @Bug_Fixed_On = null
	
	IF @Tran_Type ='I'
	
		Begin
		
			select @Bug_ID = Isnull(max(Bug_ID),0) + 1 From T0100_Bug_Report  WITH (NOLOCK)
			
			SELECT @Bug_Code = 'B' + DATA  FROM dbo.F_Format('00000',@Bug_ID) 
					
			INSERT INTO T0100_BUG_REPORT
	                      (Bug_ID, Bug_Code, Bug_Type, Bug_Description, Bug_Shanp_Short, Bug_Severity, Bug_Priority, Bug_Reported_By, Bug_Reported_On, 
	                      Bug_Assigned_On, Bug_Exp_Fix_Date, Bug_Fixed_By, Bug_Fixed_On, Bug_Status, Bug_Comment)
			VALUES     (@Bug_ID, @Bug_Code, @Bug_Type, @Bug_Description, @Bug_Shanp_Short, @Bug_Severity, @Bug_Priority, @Bug_Reported_By, @Bug_Reported_On, 
	                      @Bug_Assigned_On, @Bug_Exp_Fix_Date, @Bug_Fixed_By, @Bug_Fixed_On, @Bug_Status, @Bug_Comment)			
		End
		
	else if @Tran_Type = 'U'
		Begin
			UPDATE    T0100_BUG_REPORT
			SET       Bug_Type = @Bug_Type, Bug_Description = @Bug_Description, 
                      Bug_Shanp_Short = @Bug_Shanp_Short, Bug_Severity = @Bug_Severity, Bug_Priority = @Bug_Priority, Bug_Reported_By = @Bug_Reported_By, 
                      Bug_Reported_On = @Bug_Reported_On, Bug_Assigned_On = @Bug_Assigned_On, Bug_Exp_Fix_Date = @Bug_Exp_Fix_Date, 
                      Bug_Fixed_By = @Bug_Fixed_By, Bug_Fixed_On = @Bug_Fixed_On, Bug_Status = @Bug_Status, Bug_Comment = @Bug_Comment			
			Where Bug_ID = @Bug_ID
		End
	else if @Tran_Type ='D'
		begin
			Delete From T0100_Bug_Report where Bug_ID = @Bug_ID
		End
	
	RETURN




