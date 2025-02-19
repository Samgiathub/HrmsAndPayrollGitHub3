
---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0090_Hrms_Employee_introspection] --NIKUNJ 06/OCT/2009

     @Emp_Inspection_Id		Numeric(18, 0)	output
	,@Appr_Detail_Id		Numeric(18, 0)	
	,@For_Date				DateTime	
	,@Que_Id				Numeric(18, 0)	
	,@Answer				nVarchar(1000)  --Changed by Deepali -04Jun22
	,@Emp_Status			Int	
	,@Inspection_Status		Int	
	,@Que_Rate              Int
	,@Trans_Type			Char(1)
	,@Cmp_ID  numeric(18,0)
		
AS  
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
 
    
If @Emp_Inspection_Id =0  
Set @Emp_Inspection_Id = null  
     
If @Appr_Detail_Id = 0   
Set @Appr_Detail_Id =null    
   
 If @Trans_Type  = 'I'  
  Begin  
           
   SELECT  @Emp_Inspection_Id	 = Isnull(max(Emp_Inspection_Id	),0) + 1  From dbo.T0090_Hrms_Employee_Introspection  WITH (NOLOCK)
    
   INSERT INTO dbo.T0090_Hrms_Employee_Introspection  
              (Emp_Inspection_Id, Appr_Detail_Id, For_Date, Que_Id, Answer, Emp_Status, Inspection_Status,Que_Rate,Cmp_ID)                
   VALUES     
	           (@Emp_Inspection_Id, @Appr_Detail_Id, getdate(), @Que_Id, @Answer, @Emp_Status, @Inspection_Status,@Que_Rate,@Cmp_ID)   
  End  
 Else if @Trans_Type = 'U'  
  Begin  
   UPDATE dbo.T0090_Hrms_Employee_Introspection  
          SET 
			  For_Date			=	@For_Date,			  
			  Answer			=	@Answer,			  
			  Inspection_Status =	@Inspection_Status,
			  Que_Rate			=	@Que_Rate	
	  WHERE   Emp_Inspection_Id =   @Emp_Inspection_Id  

   End  

 Else if @Trans_Type = 'D'  
  Begin  
    Delete From dbo.T0090_Hrms_Employee_Introspection Where Emp_Inspection_Id = @Emp_Inspection_Id  
      
  End  
 RETURN  
