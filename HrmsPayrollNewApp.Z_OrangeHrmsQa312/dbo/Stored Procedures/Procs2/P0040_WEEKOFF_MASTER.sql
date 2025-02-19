



---13/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0040_WEEKOFF_MASTER] 
	@W_ID		numeric output ,
	@Cmp_ID		numeric,
	@Branch_ID	numeric,
	@Weekoff_Name	varchar(20),
	@Weekoff_Day	numeric(3,1),
	@Login_ID		numeric(20)=0,
	@Tran_Type		char(1)
	,@User_Id numeric(18,0) = 0
    ,@IP_Address varchar(30)= '' --Add By Paras 18-10-2012
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

declare @OldValue as Varchar(Max)
declare @OldWeekName as Varchar(20)
declare @OldWeekDay as Varchar(5)
declare @OldLoginID as Varchar(20)
declare @OldWeekDate as varchar(20)

set @OldWeekName =''
set @OldWeekDay =''
set @OldLoginID=''
set @OldWeekDate =''

	
	 IF @Branch_ID =0
		SET @Branch_ID = NULl
		
	 if @Login_ID = 0
		set @Login_ID = null
		
		
	 if @Tran_Type ='I' 
		
		Begin 
			if exists(Select Branch_ID from T0040_weekoff_Master WITH (NOLOCK) where BRanch_ID=@BRanch_ID and cmp_ID=@Cmp_ID and upper(Weekoff_Name) = upper(@Weekoff_Name))
			  Begin 
					raiserror('@@Already Exits@@',16,2)
				return
			  End
			
				select @W_ID = isnull(max(W_ID),0) +1 from T0040_WEEKOFF_MASTER WITH (NOLOCK)		
				INSERT INTO T0040_WEEKOFF_MASTER
				                      (W_ID, Cmp_ID, Branch_ID, Weekoff_Name, Weekoff_Day, Login_ID, System_Date)
				SELECT @W_ID, @Cmp_ID, @Branch_ID, @Weekoff_Name, @Weekoff_Day, @Login_ID, GETDATE()
				
				set @OldValue = 'New Value' + '#'+ 'Week Name :' +ISNULL( @Weekoff_Name,'') + '#' + 'Week Day :' +CAST(ISNULL( @Weekoff_Day,0)as varchar(5)) + '#' + 'Login Id :' + CAST(ISNULL(@Login_ID,0) AS VARCHAR(20)) + '#' + '"Short Fall Days :' +CAST( ISNULL( GETDATE(),0)AS VARCHAR(20)) 
		end
	 else if @Tran_Type ='U'
		begin
		
		select @OldWeekName  =ISNULL(Weekoff_Name,'') ,@OldWeekDay  =CAST(ISNULL(Weekoff_Day,'')as varchar(5)),@OldLoginID  = cast(isnull(Login_ID,0)as varchar(20)),@OldWeekDate =CAST( isnull(System_Date,0)as  varchar(20)) From dbo.T0040_WEEKOFF_MASTER WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and W_ID = @W_ID
				Update T0040_WEEKOFF_MASTER
				set Weekoff_Day = @Weekoff_Day, Login_ID = @Login_ID ,Branch_ID =@Branch_ID ,system_Date =getdate()
				where W_ID =@W_ID and Weekoff_Name  = @Weekoff_Name
				
				set @OldValue = 'old Value' + + '#'+ 'Week Name :' +ISNULL( @OldWeekName,'') + '#' + 'Week Day :' + CAST(ISNULL( @OldWeekDay,0)as varchar(5)) + '#' + 'Login Id :' + CAST(ISNULL(@OldLoginID,0) AS VARCHAR(20)) + '#' + '"Short Fall Days :' +CAST( ISNULL( @OldWeekDate,0)AS varchar(20)) 
               + 'New Value' + '#'+ 'Week Name :' +ISNULL( @Weekoff_Name,'') + '#' + 'Week Day :' +CAST(ISNULL(@Weekoff_Day,0)as varchar(5)) + '#' + 'Login Id :' + CAST(ISNULL(@Login_ID,0) AS VARCHAR(20)) + '#' + '"Short Fall Days :' +CAST( ISNULL( GETDATE(),0)AS VARCHAR(20)) 
		end
	exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'WeekOff Master',@OldValue,@W_ID,@User_Id,@IP_Address
	
	
	RETURN




