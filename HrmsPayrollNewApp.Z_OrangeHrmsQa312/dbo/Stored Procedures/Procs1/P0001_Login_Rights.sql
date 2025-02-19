



---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0001_Login_Rights]
	    @Login_Type_ID numeric(18) output
            ,@Login_Type  varchar(50)	
            ,@Is_Save  Numeric(1,0)	
            ,@Is_Edit  Numeric(1,0)	
            ,@Is_Delete  Numeric(1,0)	
            ,@Is_Reports Numeric(1,0)
            ,@tran_type char
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

if @tran_type ='I' 
		begin
		
			if exists (Select Login_Type_ID  from T0001_Login_Type WITH (NOLOCK) Where Login_Type=@Login_Type) 
				begin
					set @Login_Type_ID=0
					RETURN 
				end
					select @Login_Type_ID = isnull(max(Login_Type_ID),0) + 1 from T0001_Login_Type WITH (NOLOCK)
						
					insert into T0001_Login_Type(
		     		Login_Type_ID
                   ,Login_Type  	
                   ,Is_Save  
                   ,Is_Edit 	
                   ,Is_Delete	
                   ,Is_Report
             )values(
					 @Login_Type_ID 

            
            ,@Login_Type  	
            ,@Is_Save  	
            ,@Is_Edit  	
            ,@Is_Delete
            ,@Is_Reports) 	
            
            	
            end 
	else if @tran_type ='U' 
		begin
			      		
					
				Update T0001_Login_Type 
				set    Login_Type_ID = @Login_Type_ID 

           
            ,Login_Type  	=@Login_Type
            ,Is_Save  =@Is_Save
            ,Is_Edit 	=@Is_Edit
            ,Is_Delete	=@Is_Delete
            ,Is_Report=@Is_Reports
            
				where Login_Type_ID = @Login_Type_ID   
		end	
	else if @tran_type ='D'
		Begin
			delete  from T0001_Login_Type where Login_Type_ID=@Login_Type_ID 
		end
			

	RETURN


	

