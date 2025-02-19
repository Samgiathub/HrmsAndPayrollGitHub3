



---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0090_emp_Evaluation_Detail]   

	 @Evalution_ID numeric(18,0) output,  
	 @Emp_ID  numeric(18,0),  
	 @Cmp_ID   numeric(18,0),  
	 @Grade   numeric(18,0),  
	 @Conducted_Date DateTime,  
	 @Comments  varchar(1000) ,  
	 @Tran_Type char(1)  

AS 
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

 if @Tran_Type ='I'      
	  Begin   
  
  		select @Evalution_ID = isnull(max(Evalution_ID),0) + 1 from T0090_Emp_Evaluation_Detail  WITH (NOLOCK) 
    
		   insert into T0090_Emp_Evaluation_Detail(Evalution_ID,Emp_ID,Cmp_ID,Grade,Conducted_Date,Comments)  
		   values(@Evalution_ID,@Emp_ID,@Cmp_ID,@Grade,@Conducted_Date,@Comments)  
     
          End   
     
      
 Else if @Tran_Type='U'  
    
     Begin   
		   Update T0090_Emp_Evaluation_Detail  
     
     			set Evalution_ID =@Evalution_ID,  
			    Emp_ID=@Emp_ID,  
		            Cmp_ID=@Cmp_ID,  
		            Grade=@Grade,  
		            Conducted_Date=@Conducted_Date,  
		            Comments=@Comments
		   where Evalution_ID=@Evalution_ID        
     end  
    
  Else if @Tran_Type='D'  
	Begin	   

 	Delete from T0090_Emp_Evaluation_Detail where Evalution_ID=@Evalution_ID  
	
	end   
   
 RETURN  
  
  


