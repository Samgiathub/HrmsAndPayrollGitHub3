




CREATE PROCEDURE [dbo].[P0040_Singnature_Master]
			 @Sign_Type_ID numeric(18) output
            ,@Cmp_ID numeric(18,0)
            ,@Sign_Type varchar(20)
            ,@Sign_Name  varchar(20)
            ,@Sign_Designation  varchar(20)	
            ,@Sign_Image_Name  varchar(20)
            ,@Sign_Def_ID Numeric(1,0)
            ,@tran_type char
AS

		SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON


  if @Sign_Image_Name = '' 
     set @Sign_Image_Name = ''

 
	If @tran_type ='I' 
		begin	  
	     
		  select @Sign_Type_ID = isnull(max(Sign_Type_ID),0) + 1 from T0040_Signature_Master WITH (NOLOCK)
		  
			
		  Insert into T0040_Signature_Master(Sign_Type_ID,Cmp_ID,Sign_Type,Sign_Name,Sign_Designation,Sign_Image_name,Sign_Def_ID) 
		  
			values(@Sign_Type_ID,@Cmp_ID,@Sign_Type,@Sign_Name
			,@Sign_Designation ,@Sign_Image_name ,@Sign_Def_ID)
            end 
	else if @tran_type ='U' 
		
		 
		Begin
		
				Update T0040_Signature_Master 
				set    Sign_Type_ID = @Sign_Type_ID 
                       ,Cmp_ID =@Cmp_ID
                       ,Sign_Type=@Sign_Type
                       ,Sign_Name=@Sign_Name
                       ,Sign_Designation=@Sign_Designation
                       ,Sign_Image_name=@Sign_Image_name
                       ,Sign_Def_ID=@Sign_Def_ID   
			where Sign_Type_ID = @Sign_Type_ID   
				
				end
	else if @tran_type ='D' 
	
	       Begin 
	         Delete from T0040_Signature_master where Sign_Type_ID = @Sign_Type_ID
	        
	       End
	
	return


	

