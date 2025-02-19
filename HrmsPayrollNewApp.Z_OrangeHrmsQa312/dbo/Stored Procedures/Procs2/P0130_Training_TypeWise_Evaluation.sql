

CREATE PROCEDURE [dbo].[P0130_Training_TypeWise_Evaluation]  
	@Training_Evaluation_ID		numeric(18, 0) output
	,@Training_Type_ID			numeric(18, 0) 
	,@Training_ID				numeric(18, 0)
	,@Emp_ID					numeric(18, 0)
	,@Financial_Year				varchar(50)
	,@Desired					numeric(18, 0)
	,@Present					numeric(18, 0)
	,@cmp_id					numeric(18, 0)
	,@Trans_Type				varchar(1)  
	,@User_Id					numeric(18,0) = 0 
    ,@IP_Address				varchar(30)= '' 
AS

        SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON

  if @Trans_Type = 'I'	 
	Begin  	
		select @Training_Evaluation_ID = Isnull(max(Training_Evaluation_ID),0) + 1  From T0130_Training_TypeWise_Evaluation WITH (NOLOCK) 
		INSERT INTO T0130_Training_TypeWise_Evaluation  
						(  Training_Evaluation_ID
							,Cmp_ID
							,Emp_ID
							,Financial_Year
							,Training_Type_ID
							,Training_ID
							,Desired
							,Present
							)  
 				VALUES     (
 							@Training_Evaluation_ID
							,@cmp_id
							,@Emp_ID
							,@Financial_Year
							,@Training_Type_ID									
							,@Training_ID
							,@Desired
							,@Present
						)		
	End


RETURN  
  
  


