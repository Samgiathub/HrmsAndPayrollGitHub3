
---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0091_Employee_Goal_Score]

	 @Emp_Goal_S_id	numeric(18, 0)	output
	,@appr_detail_id	numeric(18, 0)	
	,@Emp_Goal_ID	numeric(18, 0)	
	,@Goal_rate	int	
	,@comments	nvarchar(500)	--Changed by Deepali -04Jun22
	,@Goal_status	int	
	,@Emp_status	int	
	,@Trans_Type			Char(1)
		
AS  
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON  
    
If @Emp_Goal_ID =0  
Set @Emp_Goal_ID = null  
     
If @Appr_Detail_Id = 0   
Set @Appr_Detail_Id =null   
   
   
 If @Trans_Type  = 'I'  
  Begin  
           
   SELECT  @Emp_Goal_S_id	= Isnull(max(Emp_Goal_S_id	),0) + 1  From T0091_Employee_Goal_Score WITH (NOLOCK) 
    
   INSERT INTO T0091_Employee_Goal_Score  
              ( Emp_Goal_S_id
				,appr_detail_id
				,For_date
				,Emp_Goal_ID
				,Goal_rate
				,comments
				,Goal_status
				,Emp_status
			)                
   VALUES     
	       (	@Emp_Goal_S_id
				,@appr_detail_id
				,getdate()
				,@Emp_Goal_ID
				,@Goal_rate
				,@comments
				,@Goal_status
				,@Emp_status
			)      
  End  
  
 Else if @Trans_Type = 'U'  
  Begin  
  
   UPDATE T0091_Employee_Goal_Score  
          SET 
			  comments			=	@comments,			  
			  Goal_status =	@Goal_status,
			  Goal_rate			=	@Goal_rate				  
	  WHERE   Emp_Goal_S_id =   @Emp_Goal_S_id  

   End  

 Else if @Trans_Type = 'D'  

  Begin  

    Delete From T0091_Employee_Goal_Score Where Emp_Goal_S_id = @Emp_Goal_S_id  
      
  End  
 RETURN  
  
