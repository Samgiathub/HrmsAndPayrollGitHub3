



---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0130_HRMS_TRAINING_FEEDBACK_DETAILS_SUPER]
	@Training_Apr_Detail_ID numeric(18,0) output,
	@Training_Apr_ID	  Numeric(18,0),
	@Emp_ID               Numeric(18,0),   
	@Cmp_ID				  Numeric(18,0)	,
	@Emp_S_ID             Numeric(18,0),
	@Emp_Feedback         Varchar(20),
	@Superior_Feedback    Varchar(20),
	@Emp_Feedback_Date    Datetime,
	@Sup_feedback_date    DateTime,
	@Emp_Eval_Rate        numeric(18,2),
	@Sup_Eval_Rate        numeric(18,2),
	@Is_Attend            char(1),
	@tran_type            char(1)

AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

     -- Change by Falak 09-Jun-2010
    
    if @Emp_Feedback = ''
		set @Emp_Feedback = null
	
	if @Emp_Eval_Rate = 0
		set @Emp_Eval_Rate = null
	
	if @Emp_Feedback_Date = ''
		set @Emp_Feedback_Date = null

      
	If @tran_type ='I' 
	   Begin
	
	      
			select @Training_Apr_Detail_ID = Isnull(max(Training_Apr_Detail_ID),0) + 1 	From T0130_HRMS_TRAINING_FEEDBACK_DETAILS  WITH (NOLOCK)
		        
			insert into T0130_HRMS_TRAINING_FEEDBACK_DETAILS
													(
														Training_Apr_Detail_ID, 
														Training_Apr_ID,
														Emp_ID,
														Cmp_ID,
														Emp_S_ID,
														Emp_Feedback,
														Superior_Feedback,
														Emp_Feedback_Date,                       				                 	  
														Sup_feedback_date, 
														Emp_Eval_Rate,
														Sup_Eval_Rate,
														Is_Attend
													)
								Values 
													(
														@Training_Apr_Detail_ID ,
														@Training_Apr_ID,@Emp_ID, 
														@Cmp_ID,
														@Emp_S_ID,
														@Emp_Feedback,
														@Superior_Feedback,           		
														@Emp_Feedback_Date,
														@Sup_feedback_date,
														@Emp_Eval_Rate,
														@Sup_Eval_Rate,
														@Is_Attend
													)                            
				
	   End
 
	
	   Else if @tran_type='U'
		Begin
		   
			Update T0130_HRMS_TRAINING_FEEDBACK_DETAILS
				set  Training_Apr_Detail_ID= @Training_Apr_Detail_ID,
					 Training_Apr_ID=@Training_Apr_ID  ,
					 Emp_ID=@Emp_ID ,              
					 Cmp_ID=@Cmp_ID	,			  
					 Emp_S_ID= @Emp_S_ID  ,          
					 Emp_Feedback=  @Emp_Feedback  ,     
					 Superior_Feedback = @Superior_Feedback,
					 Emp_Feedback_Date=@Emp_Feedback_Date,
					 Sup_feedback_date=@Emp_Feedback_Date , 
					 Emp_Eval_Rate= @Emp_Eval_Rate , 
					 Sup_Eval_Rate = @Sup_Eval_Rate,       
					 Is_Attend=@Is_Attend where Training_Apr_Detail_ID =@Training_Apr_Detail_ID
		End
	 
	   Else if @tran_type ='D' 
	    Begin
		
			Delete from T0130_HRMS_TRAINING_FEEDBACK_DETAILS where Training_Apr_Detail_ID =@Training_Apr_Detail_ID
		
			if Exists (Select Training_Apr_ID from T0120_Training_Approval WITH (NOLOCK) where Training_Apr_ID =@Training_Apr_ID)
				Begin
					Delete from T0120_Training_Approval where Training_Apr_ID=@Training_Apr_ID
				End	
	    End
	RETURN




