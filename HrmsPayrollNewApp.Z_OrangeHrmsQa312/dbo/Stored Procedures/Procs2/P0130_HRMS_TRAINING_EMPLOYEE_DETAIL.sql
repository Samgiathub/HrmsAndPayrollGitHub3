

CREATE PROCEDURE [dbo].[P0130_HRMS_TRAINING_EMPLOYEE_DETAIL]  
	@Tran_emp_Detail_ID		numeric(18, 0) output
	,@Training_App_ID		numeric(18, 0) 
	,@Training_Apr_ID		numeric(18, 0)
	,@Emp_ID				numeric(18, 0)
	,@Emp_tran_status		int
	,@cmp_id				numeric(18, 0)
	,@Trans_Type			varchar(1)  
	,@User_Id numeric(18,0) = 0 -- added By Mukti 18082015
    ,@IP_Address varchar(30)= '' -- added By Mukti 18082015
AS 

		SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON

--Added By Mukti 18082015(start)
	declare @OldValue			as varchar(max)
	declare @OldTraining_Apr_ID as varchar(20)
	declare @OldEmp_tran_status as varchar(20)
--Added By Mukti 18082015(end)

  if @Training_App_ID = 0
  set @Training_App_ID = null
  
  if @Training_Apr_ID = 0
  set @Training_Apr_ID = null
  
  if @Trans_Type = 'I'	 
	Begin  
		if Exists(select Tran_emp_Detail_ID from T0130_HRMS_TRAINING_EMPLOYEE_DETAIL WITH (NOLOCK) where Emp_Id = @Emp_ID and (Emp_tran_status =1 or Emp_tran_status =4) and Training_Apr_ID=@Training_Apr_ID and Training_App_Id =@Training_App_Id)  
			Begin  			
			   set @Tran_emp_Detail_ID = 0
			   return
			End 
		
	if Exists(select Tran_emp_Detail_ID from T0130_HRMS_TRAINING_EMPLOYEE_DETAIL WITH (NOLOCK) where Emp_Id = @Emp_ID and Training_Apr_ID=@Training_Apr_ID and Training_App_Id =@Training_App_Id) --Mukti(20022017) 		
		BEGIN		
			update T0130_HRMS_TRAINING_EMPLOYEE_DETAIL
			set Emp_tran_status=@Emp_tran_status
			where Emp_Id = @Emp_ID and Training_App_Id =@Training_App_Id and Training_Apr_ID=@Training_Apr_ID
		END
	ELSE
		BEGIN
			select @Tran_emp_Detail_ID = Isnull(max(Tran_emp_Detail_ID),0) + 1  From T0130_HRMS_TRAINING_EMPLOYEE_DETAIL WITH (NOLOCK) 
			INSERT INTO T0130_HRMS_TRAINING_EMPLOYEE_DETAIL  
							(  Tran_emp_Detail_ID
								,Training_App_ID
								,Training_Apr_ID
								,Emp_ID
								,Emp_tran_status
								,cmp_id
								)  
         			VALUES     (
         						@Tran_emp_Detail_ID
								,@Training_App_ID
								,@Training_Apr_ID
								,@Emp_ID
							,@Emp_tran_status
							,@cmp_id
							)
		END
	--Added By Mukti 18082015(start)
		    set @OldValue = 'New Value' + '#'+ 'Training Application ID :' + cast(Isnull(@Training_App_ID,0) as varchar(10)) + '#' + 
					    						'Training Approval ID :' + cast(Isnull(@Training_Apr_ID,0) as varchar(10)) + '#' + 
												'Employee ID :' + cast(Isnull(@Emp_ID,0) as varchar(10)) + '#' + 
												'Status :' + cast(Isnull(@Emp_tran_status,0) as varchar(10))  
		    
	--Added By Mukti 18082015(end)
		End

else if @Trans_Type = 'U'  
 Begin  
     
     if Not Exists (select Tran_emp_Detail_ID from T0130_HRMS_TRAINING_EMPLOYEE_DETAIL WITH (NOLOCK) where Emp_Id = @Emp_ID and Training_App_Id =@Training_App_Id)  
      Begin  
        select @Tran_emp_Detail_ID = Isnull(max(Tran_emp_Detail_ID),0) + 1  From T0130_HRMS_TRAINING_EMPLOYEE_DETAIL WITH (NOLOCK) 
		INSERT INTO T0130_HRMS_TRAINING_EMPLOYEE_DETAIL  
                          (Tran_emp_Detail_ID,
							Training_App_Id,Training_Apr_ID,Emp_ID,Emp_tran_status, cmp_id)  
        VALUES     (@Tran_emp_Detail_ID,@Training_App_Id,@Training_Apr_ID,@Emp_ID,@Emp_tran_status,@cmp_id)  
        
       	--Added By Mukti 18082015(start)
				set @OldValue = 'New Value' + '#'+ 'Training Application ID :' + cast(Isnull(@Training_App_ID,0) as varchar(10)) + '#' + 
					    							'Training Approval ID :' + cast(Isnull(@Training_Apr_ID,0) as varchar(10)) + '#' + 
													'Employee ID :' + cast(Isnull(@Emp_ID,0) as varchar(10)) + '#' + 
													'Status :' + cast(Isnull(@Emp_tran_status,0) as varchar(10))  
			    
		--Added By Mukti 18082015(end) 
      End  
      else
        begin
			--Added By Mukti 18082015(start)
				select @OldEmp_tran_status=Emp_tran_status,@OldTraining_APR_Id =Training_APR_Id,@Tran_emp_Detail_ID=Tran_emp_Detail_ID
				from T0130_HRMS_TRAINING_EMPLOYEE_DETAIL WITH (NOLOCK) where  Emp_Id = @Emp_ID and Training_App_Id =@Training_App_Id 
			--Added By Mukti 18082015(end)
			
			update T0130_HRMS_TRAINING_EMPLOYEE_DETAIL
			set Emp_tran_status=@Emp_tran_status,Training_APR_Id =@Training_APR_Id 
			where Emp_Id = @Emp_ID and Training_App_Id =@Training_App_Id 
			
			--Added By Mukti 18082015(start)
				set @OldValue = 'Old Value' + '#'+ 'Training Application ID :' + cast(Isnull(@Training_App_ID,0) as varchar(10)) + '#' + 
													'Training Approval ID :' + cast(Isnull(@OldTraining_Apr_ID,0) as varchar(10)) + '#' + 
													'Employee ID :' + cast(Isnull(@Emp_ID,0) as varchar(10)) + '#' + 
													'Status :' + cast(Isnull(@OldEmp_tran_status,0) as varchar(10)) + '#' + 
								'New Value' + '#'+ 'Training Application ID :' + cast(Isnull(@Training_App_ID,0) as varchar(10)) + '#' + 
					    							'Training Approval ID :' + cast(Isnull(@Training_Apr_ID,0) as varchar(10)) + '#' + 
													'Employee ID :' + cast(Isnull(@Emp_ID,0) as varchar(10)) + '#' + 
													'Status :' + cast(Isnull(@Emp_tran_status,0) as varchar(10))  
			--Added By Mukti 18082015(end) 
        end      
 End  

else if @Trans_Type = 'D'  
 Begin  
	--Added By Mukti 18082015(start)
				select @OldEmp_tran_status=Emp_tran_status,@OldTraining_APR_Id =Training_APR_Id
				from T0130_HRMS_TRAINING_EMPLOYEE_DETAIL WITH (NOLOCK) where  Emp_Id = @Emp_ID and Training_App_Id =@Training_App_Id 
	--Added By Mukti 18082015(end)
     Delete from T0130_HRMS_TRAINING_EMPLOYEE_DETAIL Where Tran_emp_Detail_ID=@Tran_emp_Detail_ID and Emp_ID=@Emp_ID and cmp_id=@cmp_id 
     
      --Added By Mukti 18082015(start)
				set @OldValue = 'Old Value' + '#'+ 'Training Application ID :' + cast(Isnull(@Training_App_ID,0) as varchar(10)) + '#' + 
													'Training Approval ID :' + cast(Isnull(@OldTraining_Apr_ID,0) as varchar(10)) + '#' + 
													'Employee ID :' + cast(Isnull(@Emp_ID,0) as varchar(10)) + '#' + 
													'Status :' + cast(Isnull(@OldEmp_tran_status,0) as varchar(10))
	 --Added By Mukti 18082015(end)
 End  
 
 	--exec P9999_Audit_Trail @Cmp_ID,@Trans_Type,'Emp Invited for Training',@OldValue,@Tran_emp_Detail_ID,@User_Id,@IP_Address 
RETURN  
  
  


