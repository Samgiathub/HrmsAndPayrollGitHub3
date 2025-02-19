

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[P_Home_Change_Password]
   @Cmp_ID numeric(18,0),  
   @Branch_ID numeric(18,0),
   @emp_id numeric(18,0) 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON		
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ARITHABORT ON

  If exists(select Module_Id From dbo.T0011_module_detail WITH (NOLOCK) where Cmp_id=@Cmp_ID and module_name='Payroll' and Isnull(chg_pwd,0)=0)			
			begin
				
				Declare @Enable_Validation	As TinyInt
				Declare @Pass_Exp_Days		As Numeric(18,0)
				Declare @Reminder_Days		As Numeric(18,0)
				Declare @Effective_From_Date As Datetime
				Declare @Notice_Days		As Numeric(18,0)
				Set @Notice_Days = 0
				
				Select @Enable_Validation = Isnull(Enable_Validation,0), @Pass_Exp_Days = Isnull(Pass_Exp_Days,0), 
						@Reminder_Days = Isnull(Reminder_Days,0) From dbo.T0011_Password_Settings WITH (NOLOCK) Where Cmp_ID = @Cmp_ID
						
				If @Enable_Validation = 1 And @Pass_Exp_Days > 0
					Begin

						Select @Effective_From_Date = Isnull(Max(Effective_From_Date),'') From dbo.T0250_Change_Password_History WITH (NOLOCK) Where Cmp_ID = @Cmp_ID And Emp_ID = @Emp_ID
						
						
						--If @Effective_From_Date = '1900-01-01 00:00:00.000'
						--begin
						--		Select @Effective_From_Date  = System_Date From T0080_Emp_Master WITH (NOLOCK) Where Cmp_ID = @Cmp_ID And Emp_ID = @emp_id 
								
						--		if @Effective_From_Date IS NULL
						--			set @Effective_From_Date = '1900-01-01 00:00:00.000'
						--end
						
						Declare @Expire_Date datetime
						declare @Notice_Date datetime
						declare @Reminder_Date datetime

						
						
						If @Effective_From_Date = '1900-01-01 00:00:00.000' -- Deepal add new if condition line 29112021
						begin
							set @Expire_Date = GETDATE() - 1
						end
						else
						Begin --  Deepal add new if condition line 29112021
							set @Expire_Date = DATEADD(dd, @Pass_Exp_Days , @Effective_From_Date) 
						end --  Deepal add new if condition line 29112021

						
						If @Expire_Date <= getDate() or @Expire_Date >= getDate()
						Begin

							set @Notice_Date = DATEADD(dd, @Pass_Exp_Days - @Reminder_Days , @Effective_From_Date)

							set @Reminder_Date = DATEADD(dd, (@Reminder_Days)*-1 , @Expire_Date)

						 IF @Notice_Date <= getdate()
							Begin
								
								Set @Notice_Days =ABS(DATEDIFF(DAY, @Expire_Date,GETDATE()))

								if @Notice_Days  >= 0
								begin
									Update dbo.T0080_Emp_Master WITH (ROWLOCK) Set Chg_Pwd = 0 Where Cmp_id = @Cmp_Id and Emp_ID = @Emp_Id
								end
							End
						
						End
														
					End				
				else
							Begin
								Select @Effective_From_Date = Isnull(Max(Effective_From_Date),'') From dbo.T0250_Change_Password_History Where Cmp_ID = @Cmp_ID And Emp_ID = @Emp_ID
								if @Effective_From_Date <> '' 
									Update dbo.T0080_Emp_Master WITH (ROWLOCK) Set Chg_Pwd = 2 Where Cmp_id = @Cmp_Id and Emp_ID = @Emp_Id		 --Added By Gadriwala 10012013
							End
							
				--select  Isnull(Em.Chg_Pwd,0)Chg_Pwd, Md.module_status, @Notice_Days As Notice_Days ,DATEADD(dd, @Pass_Exp_Days , @Effective_From_Date) As Expire_Date,@Pass_Exp_Days As Pass_Exp_Days   --Change By Jaina 29-11-2016
				--From dbo.T0080_Emp_Master As Em WITH (NOLOCK) 
				--Inner Join dbo.T0011_Module_Detail As MD WITH (NOLOCK) On Em.Cmp_id=Md.Cmp_Id and module_name='Payroll'
				--Where Em.emp_Id=@emp_id And EM.Cmp_Id=@Cmp_ID 		

					select  Isnull(Em.Chg_Pwd,0)Chg_Pwd, Md.module_status, @Notice_Days As Notice_Days ,@Expire_Date As Expire_Date,@Pass_Exp_Days As Pass_Exp_Days   --Change By Jaina 29-11-2016
				From dbo.T0080_Emp_Master As Em WITH (NOLOCK) 
				Inner Join dbo.T0011_Module_Detail As MD WITH (NOLOCK) On Em.Cmp_id=Md.Cmp_Id and module_name='Payroll'
				Where Em.emp_Id=@emp_id And EM.Cmp_Id=@Cmp_ID 		
				
			
			end
		ELSE	
			BEGIN
			
				select  2 as Chg_Pwd, Md.module_status, 0 As Notice_Days From dbo.T0080_Emp_Master As Em  WITH (NOLOCK)
					Inner Join dbo.T0011_Module_Detail As MD WITH (NOLOCK) 
				On Em.Cmp_id=Md.Cmp_Id Where Em.emp_Id=@emp_id And EM.Cmp_Id=@Cmp_ID and MD.module_name = 'Payroll' 
			End			
END

