  
  
---20/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---  
CREATE  PROCEDURE [dbo].[P0040_Speciality_Master]  
@Speciality_ID as numeric output,  
@Cmp_ID numeric(18,0),  
@Speciality_Name as varchar(100),  
@Description as varchar(4000),  
@tran_type as char(1)  
AS  
  
SET NOCOUNT ON   
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
SET ARITHABORT ON  
   set @Speciality_Name = dbo.fnc_ReverseHTMLTags(@Speciality_Name) --Ronak_060121  
   set @Description = dbo.fnc_ReverseHTMLTags(@Description) --Ronak_060121   
BEGIN  
if @tran_type = 'I'  
   begin  
   If  Exists(Select Speciality_ID From T0040_Speciality_Master WITH (NOLOCK) Where Cmp_Id = @Cmp_ID And   
        Speciality_Name = @Speciality_Name)  
     begin  
      set @Speciality_ID = 0  
      Return  
     end        
        
    select @Speciality_ID = isnull(max(Speciality_ID),0) + 1 from T0040_Speciality_Master WITH (NOLOCK)  
  
    Insert Into T0040_Speciality_Master(Speciality_ID,Speciality_Name,Cmp_Id,Description)  
    Values(@Speciality_ID,@Speciality_Name,@Cmp_ID,@Description)  
end  
  
if @tran_type = 'U'  
   begin  
   If  Exists(Select Speciality_ID From T0040_Speciality_Master WITH (NOLOCK) Where Cmp_Id = @Cmp_ID And   
        Speciality_Name = @Speciality_Name AND Speciality_ID <> @Speciality_ID)  
     begin  
      set @Speciality_ID = 0  
      Return  
     end          
       
 Update T0040_Speciality_Master  
  set    Speciality_Name = @Speciality_Name,  
     Description = @Description  
 where   Speciality_ID = @Speciality_ID and cmp_id=@Cmp_ID         
     
end  
  
  
else if @tran_type = 'D'  
 begin  
      
  delete from T0040_Speciality_Master where  Speciality_ID=@Speciality_ID  
    
 end  
END  
  
  
  
  