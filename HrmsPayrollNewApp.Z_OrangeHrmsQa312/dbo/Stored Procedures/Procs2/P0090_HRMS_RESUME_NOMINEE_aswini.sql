


-- =============================================
-- Author:		Sneha 
-- ALTER date: 15 Jul 2013
-- Description:	<Description,,>
---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0090_HRMS_RESUME_NOMINEE_aswini]
		 @Row_ID		numeric(18,0) output
		,@Cmp_id		numeric(18,0)
	    ,@Resume_ID		numeric(18,0)
	    ,@Member_Name   varchar(50)
	    ,@Member_Age    numeric(18,0)
	    ,@Relationship  varchar(50)
	    ,@Occupation    varchar(50)
	    ,@Comments      varchar(100)
	    ,@Member_Date_of_Birth datetime
	    ,@Relationship_ID numeric(18,0)
	    ,@Transtype	    char(1) 
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON



	 if @Transtype = 'I'
		begin
			 if Not exists(Select Row_ID from T0090_HRMS_RESUME_NOMINEE WITH (NOLOCK) where  Row_ID=@Row_ID)
				BEGIN
						
						

					select @Row_ID =isnull(max(Row_ID),0) + 1 from T0090_HRMS_RESUME_NOMINEE WITH (NOLOCK)
					
					Insert into T0090_HRMS_RESUME_NOMINEE (
									Row_ID,
									Cmp_id ,
									Resume_ID ,
									Member_Name  ,
									Member_Age,
									Relationship,
									Occupation,
									Comments,
									Member_Date_of_Birth,
									Relationship_ID
								)
						values	(
									@Row_ID,
									@Cmp_id ,
									@Resume_ID ,
									@Member_Name,
									@Member_Age,
									@Relationship,
									@Occupation,
									@Comments,
									@Member_Date_of_Birth,
									@Relationship_ID
								 )
				end
					ELSE            
					 begin
						 Update T0090_HRMS_RESUME_NOMINEE 	         
						   set 
							   Member_Name = @Member_Name,
							   Member_Age = @Member_Age,
							   Relationship =@Relationship,
							   Occupation = @Occupation,
							   Comments = @Comments,
							   Member_Date_of_Birth=@Member_Date_of_Birth,
							   Relationship_ID=@Relationship_ID				
							 where Resume_ID =@Resume_ID and Row_ID	  = @Row_ID
					 end
		end
	Else if  @Transtype = 'U'   
		begin
			 Update T0090_HRMS_RESUME_NOMINEE 	         
			   set Row_ID	  = @Row_ID,
				   Member_Name = @Member_Name,
				   Member_Age = @Member_Age,
				   Relationship =@Relationship,
				   Occupation = @Occupation,
				   Comments = @Comments,
				   Member_Date_of_Birth=@Member_Date_of_Birth,
				   Relationship_ID=@Relationship_ID				
				 where Row_ID =@Row_ID
		end
		
  Else if  @Transtype = 'D'   
      Begin 
          
           Delete from T0090_HRMS_RESUME_NOMINEE where Row_ID =@Row_ID
			
      End
end


