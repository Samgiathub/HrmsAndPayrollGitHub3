



---25/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0090_HRMS_RECRUITMENT_FINAL_SCORE]
	
	@Trans_ID  numeric(18, 0) output
	,@Resume_ID numeric(18, 0)
	,@Cmp_ID    numeric(18, 0)
	,@Rec_Post_ID  numeric(18, 0) 
	,@Rec_Job_Code varchar(50)
	,@Process_ID   numeric(18, 0) 
	,@Notes        varchar(1000)
	,@Actual_Rate  numeric(18, 2)
	,@Given_Rate   numeric(18, 2)
	,@Status       Numeric(1,0)
	,@Tran_Type    Char(1)
	,@Date_OF_Join DateTime = null
	,@Basic_Salary numeric(18,2) =null
	
	
	
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	if @Tran_Type ='I' 
	
	  Begin 
	  
	      if exists(Select Trans_ID from T0090_HRMS_RECRUITMENT_FINAL_SCORE WITH (NOLOCK) where Resume_ID=@Resume_ID)
	       Begin 
	          
	           set @Trans_ID =0
	           return
	       End
	       
			 Select  @Trans_ID =isnull(max(Trans_ID),0) + 1 from T0090_HRMS_RECRUITMENT_FINAL_SCORE WITH (NOLOCK)
		      
		
			 
			 Insert into T0090_HRMS_RECRUITMENT_FINAL_SCORE
			   (Trans_ID,Resume_ID,Cmp_ID,Rec_Job_Code,Process_ID,Rec_Post_ID,Actual_Rate,Given_Rate,Notes,Status)
			   values (@Trans_ID,@Resume_ID,@Cmp_ID,@Rec_Job_Code,@Process_ID,@Rec_Post_ID,@Actual_Rate,@Given_Rate,@Notes,@Status)
			   
			   if @Status = 1 -- change by : Falak 0n 28-may-2010
				begin
					Update T0055_Resume_master set 
				
					Date_OF_Join = @Date_OF_Join,
					Basic_Salary = @Basic_salary 
			    
					where Resume_Id=@Resume_ID and Cmp_ID=@Cmp_ID 
				end 
			    
			    
	  
	  End
	  
	  Else if @Tran_Type='U'
	  
	    Begin 
				Update T0090_HRMS_RECRUITMENT_FINAL_SCORE
				   set Resume_ID=@Resume_ID,
				       Cmp_ID=@Cmp_ID,
				       Rec_Job_Code=@Rec_Job_Code,
				         Process_ID=@Process_ID,
				         Rec_Post_ID=@Rec_Post_ID,
				         Actual_Rate=@Actual_Rate,
				         Given_Rate=@Given_Rate,
				         Notes=@Notes ,
				         Status=@Status
				where Trans_ID=@Trans_ID
				
				if @Status = 1  -- change by : Falak 0n 28-may-2010
				begin
					Update T0055_Resume_master set 
				
					Date_OF_Join = @Date_OF_Join,
					Basic_Salary = @Basic_salary 
			    
					where Resume_Id=@Resume_ID and Cmp_ID=@Cmp_ID 
				end
	    End
	    
	    
	    Else if @Tran_Type ='D'
	     Begin 
	       
	        Delete from T0090_HRMS_RECRUITMENT_FINAL_SCORE where Trans_ID=@Trans_ID
	       
	     End
	
	RETURN




