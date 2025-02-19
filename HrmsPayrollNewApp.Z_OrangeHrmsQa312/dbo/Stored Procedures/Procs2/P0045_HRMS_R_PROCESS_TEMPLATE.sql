



---13/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0045_HRMS_R_PROCESS_TEMPLATE]
	 @Process_Q_ID	numeric(18, 0)	output
	,@Cmp_ID	numeric(18, 0)	
	,@Process_ID	numeric(18, 0)	
	,@QUE_Detail	varchar(500)	
	,@IS_Title	int	
	,@Is_Description	int	
	,@Is_Raiting	int	
	,@is_dynamic	int	
	,@Dis_No		int
	,@Question_Type int
	,@Question_Option varchar(1500)
	,@tran_type char(1)
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	 if @Process_ID=0
		set @Process_ID=null
	 /*******************************************************
	 ***************Created by Zalak on 29-Dec-2010***********
	 ********************************************************/
	 If @tran_type  = 'I' 
		Begin
				If Exists(select Process_Q_ID From T0045_HRMS_R_PROCESS_TEMPLATE WITH (NOLOCK)  Where cmp_ID = @cmp_id and
									(QUE_Detail = @QUE_Detail and Process_ID=@Process_ID) or (Dis_No=@Dis_No and Process_ID=@Process_ID) )
					Begin
						set @Process_Q_ID = 0
						Return 
					end
	
				select @Process_Q_ID = Isnull(max(Process_Q_ID),0) + 1 	From T0045_HRMS_R_PROCESS_TEMPLATE WITH (NOLOCK)
				
				INSERT INTO T0045_HRMS_R_PROCESS_TEMPLATE
				                      (
										     Process_Q_ID
										    ,Cmp_ID	
											,Process_ID
											,QUE_Detail
											,IS_Title	
											,Is_Description
											,Is_Raiting	
											,is_dynamic	
											,Dis_No
											,Question_Type
											,Question_Option
				                      )
								VALUES     
								(
									         @Process_Q_ID
										    ,@Cmp_ID	
											,@Process_ID
											,@QUE_Detail
											,@IS_Title	
											,@Is_Description
											,@Is_Raiting	
											,@is_dynamic
											,@Dis_No		
											,@Question_Type
											,@Question_Option																			 
								)
														
		End
	ELSE If @tran_type  = 'U' --24 sep 2012
		begin
					
			--=============START==========		Added By Ashwin 06/10/2016
			IF EXISTS(SELECT PROCESS_Q_ID FROM T0045_HRMS_R_PROCESS_TEMPLATE WITH (NOLOCK) WHERE PROCESS_Q_ID <> @PROCESS_Q_ID AND 
						CMP_ID = @CMP_ID AND QUE_DETAIL = @QUE_DETAIL AND PROCESS_ID = @PROCESS_ID)
			BEGIN
				SET @PROCESS_Q_ID = 0
						RETURN 
			END
			--==========END===============		Added By Ashwin 06/10/2016
			
			update T0045_HRMS_R_PROCESS_TEMPLATE set
			QUE_Detail=@QUE_Detail,
			IS_Title = @IS_Title,
			Is_Description = @Is_Description,
			Is_Raiting = @Is_Raiting,
			is_dynamic = @is_dynamic,
			Dis_No = @Dis_No,
			Question_Type=@Question_Type,
			Question_Option=@Question_Option
			Where Cmp_ID=@Cmp_ID and Process_Q_ID = @Process_Q_ID
		end
	Else if @tran_type = 'D' 
		begin
				Delete From T0045_HRMS_R_PROCESS_TEMPLATE Where Process_Q_ID  = @Process_Q_ID
		end


	
	RETURN




