
---19/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0050_Scheme_Detail]
	 @Scheme_Detail_Id	Numeric(18,0)	Output
	,@Scheme_Id			Numeric(18,0)
	,@Cmp_Id			Numeric(18,0)
	,@Leave				Varchar(max)
	,@R_Cmp_Id			Numeric(18,0)
	,@R_Desg_Id			Numeric(18,0)
	,@Is_RM				TinyInt
	,@Is_BM				TinyInt
	,@App_Emp_ID		Numeric(18,0)
	,@Leave_Days		Numeric(18,0)
	,@Is_Fwd_Leave_Rej	TinyInt
	,@Rpt_Level			TinyInt
	,@Tran_Type			Varchar(1)
	,@Not_Mandatory		Tinyint = 0
	,@Aprvl_Ovtlmt		Tinyint=0 --Added by Sumit 13082015
	,@Is_HOD			Tinyint=0 --Added by Sumit 1709215
	,@Is_HR			    Tinyint=0 --Added by sneha 3-Feb-2016
	,@Is_PRM			Tinyint=0 
	,@Is_RMToRM			Tinyint=0 --Added By Jimit 05122017
	,@Is_Intimation		Tinyint=0 
	,@Dyn_Hier_ID		Numeric(18,0)
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN
	
	declare @OldValue as varchar(MAX) = ''
	declare @Approval_Overlimit_Travel_Settlmnt Tinyint = 0
	declare @Is_IT Tinyint = 0
	declare @Is_Account Tinyint = 0
	declare @Is_TravelHelpDesk Tinyint = 0
	declare @timestamp dateTime 

	If @Tran_Type = 'I'
		Begin
			Select @Scheme_Detail_Id = Isnull(Max(Scheme_Detail_Id),0)+ 1  From dbo.T0050_Scheme_Detail WITH (NOLOCK)
			Insert Into T0050_Scheme_Detail(Scheme_Detail_Id, Scheme_Id, Cmp_Id, Leave, R_Cmp_Id, R_Desg_Id, Is_RM,
					Is_BM, App_Emp_ID, Leave_Days, Is_Fwd_Leave_Rej, Rpt_Level, TimeStamp,Not_Mandatory,Approval_Overlimit_Travel_Settlmnt,Is_HOD,Is_HR,Is_PRM,is_RmToRm,Is_Intimation,Dyn_Hier_Id)
				Values(@Scheme_Detail_Id, @Scheme_Id, @Cmp_Id, @Leave, @R_Cmp_Id, @R_Desg_Id, @Is_RM,
					@Is_BM, @App_Emp_ID, @Leave_Days, @Is_Fwd_Leave_Rej, @Rpt_Level, Getdate(),@Not_Mandatory,@Aprvl_Ovtlmt,@Is_HOD,@Is_HR,@IS_PRM,@Is_RMToRM,@Is_Intimation,@Dyn_Hier_ID)

				set @OldValue = 'New Value' + '#'+ 'Scheme_Detail_Id :' + cast(ISNULL(@Scheme_Detail_Id,0) as varchar(5)) 
					  + '#' + 'Scheme_Id :' + cast(ISNULL(@Scheme_Id,0) as varchar(5)) 
					  + '#' + 'Cmp_Id :' + cast(isnull(@Cmp_Id,0) as varchar(5)) 
					  + '#' + 'Leave :' + cast(isnull(@Leave,0) as varchar(Max))  
					  + '#' + 'R_Cmp_Id  :' + cast(isnull(@R_Cmp_Id,0) as varchar(5)) 
					  + '#' + 'Is_RM :' + cast(isnull(@Is_RM,0) as varchar(5))
					  + '#' + 'Is_BM :' + cast(ISNULL(@Is_BM,0) as varchar(5))   
					  + '#' + 'App_Emp_ID :' + cast(ISNULL(@App_Emp_ID,0) as varchar(5))              
					  + '#' + 'Leave_Days :' + cast(ISNULL(@Leave_Days,0) as varchar(5))					  
					  + '#' + 'Is_Fwd_Leave_Rej :' + cast(ISNULL(@Is_Fwd_Leave_Rej,0) as varchar(5))
					  + '#' + 'Rpt_Level :' + cast(ISNULL(@Rpt_Level,0)  as varchar(5))
					  + '#' + 'not_mandatory :' + cast(ISNULL(@not_mandatory,0) as varchar(5)) 
					  + '#' + 'Approval_Overlimit_Travel_Settlmnt :' + cast(ISNULL(@Aprvl_Ovtlmt,0) as varchar(5)) 
					  + '#' + 'Is_HOD :' + cast(ISNULL(@Is_HOD,0)  as varchar(5))
					  + '#' + 'Is_HR :' + cast(ISNULL(@Is_HR,0)  as varchar(5))
					  + '#' + 'Is_PRM :' + cast(ISNULL(@Is_PRM,0)  as varchar(5))
					  + '#' + 'Is_RMToRM :' + cast(ISNULL(@Is_RMToRM,0)  as varchar(5))
					  + '#' + 'Is_Intimation :' + cast(ISNULL(@Is_Intimation,0)  as varchar(5))
					  + '#' + 'Dyn_Hier_Id :' + cast(ISNULL(@Dyn_Hier_Id,0)  as varchar(5))
		End
	Else If @Tran_Type = 'U'
		Begin

			SELECT @Scheme_Detail_Id = Scheme_Detail_Id,@Scheme_Id = Scheme_Id
			,@Cmp_Id= Cmp_Id
			,@Leave = Leave 
			,@R_Cmp_Id= R_Cmp_Id
			,@R_Desg_Id = R_Desg_Id
			,@Is_RM = Is_RM ,@Is_BM = Is_BM , @App_Emp_ID = App_Emp_ID,@Leave_Days = Leave_Days
			,@Is_Fwd_Leave_Rej = Is_Fwd_Leave_Rej	
			,@Rpt_Level	= Rpt_Level	
			,@TimeStamp =	TimeStamp	
			,@not_mandatory	= not_mandatory	
			,@Approval_Overlimit_Travel_Settlmnt = Approval_Overlimit_Travel_Settlmnt	
			,@Is_HOD	= Is_HOD	
			,@Is_HR	= Is_HR	
			,@Is_PRM	= Is_PRM	
			,@Is_RMToRM	 = Is_RMToRM	
			,@Is_Intimation = 	Is_Intimation	
			,@Dyn_Hier_Id = Dyn_Hier_Id	
			,@Is_IT =	Is_IT	
			,@Is_Account	= Is_Account	
			,@Is_TravelHelpDesk = Is_TravelHelpDesk

			FROM T0050_Scheme_Detail where scheme_id = @Scheme_Id and rpt_level = @Rpt_Level and cmp_id = @Cmp_Id
			
			
			SELECT @SCHEME_DETAIL_ID = ISNULL(MAX(SCHEME_DETAIL_ID),0)+ 1  FROM DBO.T0050_SCHEME_DETAIL WITH (NOLOCK)
			INSERT INTO T0050_Scheme_Detail(Scheme_Detail_Id, Scheme_Id, Cmp_Id, Leave, R_Cmp_Id, R_Desg_Id, Is_RM,
					Is_BM, App_Emp_ID, Leave_Days, Is_Fwd_Leave_Rej, Rpt_Level, TimeStamp,Not_Mandatory,Approval_Overlimit_Travel_Settlmnt,Is_HOD,Is_HR,Is_PRM,is_RmToRm,Is_Intimation,Dyn_Hier_Id)
					Values(@Scheme_Detail_Id, @Scheme_Id, @Cmp_Id, @Leave, @R_Cmp_Id, @R_Desg_Id, @Is_RM,
					@Is_BM, @App_Emp_ID, @Leave_Days, @Is_Fwd_Leave_Rej, @Rpt_Level, Getdate(),@Not_Mandatory,@Aprvl_Ovtlmt,@Is_HOD,@Is_HR,@Is_PRM,@Is_RMToRM,@Is_Intimation,@Dyn_Hier_ID)
					
					
				 set @OldValue = 'Old Value' + '#'+ 'Scheme_Detail_Id :' + cast(ISNULL(@Scheme_Detail_Id,0) as varchar(5)) 
					  + '#' + 'Scheme_Id :' + cast(ISNULL(@Scheme_Id,0) as varchar(5)) 
					  + '#' + 'Cmp_Id :' + cast(isnull(@Cmp_Id,0) as varchar(5)) 
					  + '#' + 'Leave :' + cast(isnull(@Leave,0) as varchar(Max))  
					  + '#' + 'R_Cmp_Id  :' + cast(isnull(@R_Cmp_Id,0) as varchar(5)) 
					  + '#' + 'Is_RM :' + cast(isnull(@Is_RM,0) as varchar(5))
					  + '#' + 'Is_BM :' + cast(ISNULL(@Is_BM,0) as varchar(5))   
					  + '#' + 'App_Emp_ID :' + cast(ISNULL(@App_Emp_ID,0) as varchar(5))              
					  + '#' + 'Leave_Days :' + cast(ISNULL(@Leave_Days,0) as varchar(5))					  
					  + '#' + 'Is_Fwd_Leave_Rej :' + cast(ISNULL(@Is_Fwd_Leave_Rej,0) as varchar(5))
					  + '#' + 'Rpt_Level :' + cast(ISNULL(@Rpt_Level,0)  as varchar(5))
					  + '#' + 'TimeStamp :' + cast(@TimeStamp as varchar(5))
					  + '#' + 'not_mandatory :' + cast(ISNULL(@not_mandatory,0) as varchar(5)) 
					  + '#' + 'Approval_Overlimit_Travel_Settlmnt :' + cast(ISNULL(@Approval_Overlimit_Travel_Settlmnt,0) as varchar(5)) 
					  + '#' + 'Is_HOD :' + cast(ISNULL(@Is_HOD,0)  as varchar(5))
					  + '#' + 'Is_HR :' + cast(ISNULL(@Is_HR,0)  as varchar(5))
					  + '#' + 'Is_PRM :' + cast(ISNULL(@Is_PRM,0)  as varchar(5))
					  + '#' + 'Is_RMToRM :' + cast(ISNULL(@Is_RMToRM,0)  as varchar(5))
					  + '#' + 'Is_Intimation :' + cast(ISNULL(@Is_Intimation,0)  as varchar(5))
					  + '#' + 'Dyn_Hier_Id :' + cast(ISNULL(@Dyn_Hier_Id,0)  as varchar(5))
					  + '#' + 'Is_IT :' + cast(ISNULL(@Is_IT,0)  as varchar(5))
					  + '#' + 'Is_Account :' + cast(ISNULL(@Is_Account,0)  as varchar(5))
					  + '#' + 'Is_TravelHelpDesk :' + cast(ISNULL(@Is_TravelHelpDesk,0)  as varchar(5))
			
		End
	Else If @Tran_Type = 'D'
		Begin

			

			SELECT @Scheme_Detail_Id = Scheme_Detail_Id,@Scheme_Id = Scheme_Id
			,@Cmp_Id= Cmp_Id
			,@Leave = Leave 
			,@R_Cmp_Id= R_Cmp_Id
			,@R_Desg_Id = R_Desg_Id
			,@Is_RM = Is_RM ,@Is_BM = Is_BM , @App_Emp_ID = App_Emp_ID,@Leave_Days = Leave_Days
			,@Is_Fwd_Leave_Rej = Is_Fwd_Leave_Rej	
			,@Rpt_Level	= Rpt_Level	
			,@TimeStamp =	TimeStamp	
			,@not_mandatory	= not_mandatory	
			,@Approval_Overlimit_Travel_Settlmnt = Approval_Overlimit_Travel_Settlmnt	
			,@Is_HOD	= Is_HOD	
			,@Is_HR	= Is_HR	
			,@Is_PRM	= Is_PRM	
			,@Is_RMToRM	 = Is_RMToRM	
			,@Is_Intimation = 	Is_Intimation	
			,@Dyn_Hier_Id = Dyn_Hier_Id	
			,@Is_IT =	Is_IT	
			,@Is_Account	= Is_Account	
			,@Is_TravelHelpDesk = Is_TravelHelpDesk
			FROM T0050_Scheme_Detail where scheme_id = @Scheme_Id and rpt_level = @Rpt_Level and cmp_id = @Cmp_Id


			Delete From T0050_Scheme_Detail 
				Where Leave = @Leave And Scheme_Id = @Scheme_Id

				 set @OldValue = 'Old Value' + '#'+ 'Scheme_Detail_Id :' + cast(ISNULL(@Scheme_Detail_Id,0) as varchar(5)) 
					  + '#' + 'Scheme_Id :' + cast(ISNULL(@Scheme_Id,0) as varchar(5)) 
					  + '#' + 'Cmp_Id :' + cast(isnull(@Cmp_Id,0) as varchar(5)) 
					  + '#' + 'Leave :' + cast(isnull(@Leave,0) as varchar(Max))  
					  + '#' + 'R_Cmp_Id  :' + cast(isnull(@R_Cmp_Id,0) as varchar(5)) 
					  + '#' + 'Is_RM :' + cast(isnull(@Is_RM,0) as varchar(5))
					  + '#' + 'Is_BM :' + cast(ISNULL(@Is_BM,0) as varchar(5))   
					  + '#' + 'App_Emp_ID :' + cast(ISNULL(@App_Emp_ID,0) as varchar(5))              
					  + '#' + 'Leave_Days :' + cast(ISNULL(@Leave_Days,0) as varchar(5))					  
					  + '#' + 'Is_Fwd_Leave_Rej :' + cast(ISNULL(@Is_Fwd_Leave_Rej,0) as varchar(5))
					  + '#' + 'Rpt_Level :' + cast(ISNULL(@Rpt_Level,0)  as varchar(5))
					  + '#' + 'TimeStamp :' + cast(@TimeStamp as varchar(5))
					  + '#' + 'not_mandatory :' + cast(ISNULL(@not_mandatory,0) as varchar(5)) 
					  + '#' + 'Approval_Overlimit_Travel_Settlmnt :' + cast(ISNULL(@Approval_Overlimit_Travel_Settlmnt,0) as varchar(5)) 
					  + '#' + 'Is_HOD :' + cast(ISNULL(@Is_HOD,0)  as varchar(5))
					  + '#' + 'Is_HR :' + cast(ISNULL(@Is_HR,0)  as varchar(5))
					  + '#' + 'Is_PRM :' + cast(ISNULL(@Is_PRM,0)  as varchar(5))
					  + '#' + 'Is_RMToRM :' + cast(ISNULL(@Is_RMToRM,0)  as varchar(5))
					  + '#' + 'Is_Intimation :' + cast(ISNULL(@Is_Intimation,0)  as varchar(5))
					  + '#' + 'Dyn_Hier_Id :' + cast(ISNULL(@Dyn_Hier_Id,0)  as varchar(5))
					  + '#' + 'Is_IT :' + cast(ISNULL(@Is_IT,0)  as varchar(5))
					  + '#' + 'Is_Account :' + cast(ISNULL(@Is_Account,0)  as varchar(5))
					  + '#' + 'Is_TravelHelpDesk :' + cast(ISNULL(@Is_TravelHelpDesk,0)  as varchar(5))
		End

		
			exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'Scheme Detail',@OldValue,@Scheme_Id,0,0  
END


