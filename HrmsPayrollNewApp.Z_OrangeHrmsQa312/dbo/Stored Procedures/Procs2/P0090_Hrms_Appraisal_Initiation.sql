



---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0090_Hrms_Appraisal_Initiation] --NIKUNJ 18/09/2009
     @Appr_Int_Id		Numeric(18, 0)	output
	,@For_Date			DateTime	
	,@Login_Id			Numeric(18, 0)	
	,@Invoke_Emp		Int	
	,@Invoke_Superior	Int	
	,@Invoke_Team		Int	
	,@Cmp_Id			Numeric(18, 0)	
	,@Branch_Id			Numeric(18, 0)	
	,@Trans_Type        Char(1)
AS  
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
   
  --DECLARE @str_Emp_Code as varchar(5)  
  --DECLARE @Emp_Code as varchar(5)  
    
If @Appr_Int_Id =0  
Set @Appr_Int_Id = null  
     
If @Login_Id = 0   
Set @Login_Id =null   
   
if @Branch_Id	 = 0 
set @Branch_Id	 =  null
   
 If @Trans_Type  = 'I'  
  Begin  
           
   SELECT  @Appr_Int_Id = Isnull(max(Appr_Int_Id),0) + 1  From T0090_Hrms_Appraisal_Initiation  WITH (NOLOCK)
    
   INSERT INTO T0090_Hrms_Appraisal_Initiation  
              (Appr_Int_Id,For_Date, Login_Id, Invoke_Emp, Invoke_Superior,Invoke_Team ,Cmp_Id, Branch_Id)                
   VALUES     
	           (@Appr_Int_Id, @For_Date, @Login_Id, @Invoke_Emp, @Invoke_Superior, @Invoke_Team,@Cmp_Id, @Branch_Id)   
  End  
 Else if @Trans_Type = 'U'  
  Begin  
   UPDATE T0090_Hrms_Appraisal_Initiation  
          SET 		
			 
			  For_Date   = @For_Date,			
			  Login_Id   = @Login_Id,			
			  Invoke_Emp = @Invoke_Emp,		
			  Invoke_Superior = @Invoke_Superior,
			  Invoke_Team = @Invoke_Team,
			  Cmp_Id = @Cmp_Id,			
			  Branch_Id = @Branch_Id			
						        
		  WHERE  Appr_Int_Id = @Appr_Int_Id  

   End  

 Else if @Trans_Type = 'D'  

  Begin  

    Delete From T0090_Hrms_Appraisal_Initiation Where Appr_Int_Id = @Appr_Int_Id  
      
  End  
 RETURN  
  
  
  

