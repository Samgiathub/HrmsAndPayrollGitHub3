  
  
---19/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---  
CREATE PROCEDURE [dbo].[P0040_RATING_MASTER]  
 @Rating_ID AS NUMERIC output,  
 @Title AS VARCHAR(200),  
 @CMP_ID AS NUMERIC,  
 @Description as varchar(Max),  
 @From_Rate as numeric(18,2),   
 @To_Rate as numeric(18,2),  
 @tran_type varchar(1),  
 @User_Id numeric(18,0) = 0,  
    @IP_Address varchar(30)= ''  
AS  
SET NOCOUNT ON   
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
SET ARITHABORT ON  
   set @Title = dbo.fnc_ReverseHTMLTags(@Title)  --added by Ronak 081021  
      set @Description = dbo.fnc_ReverseHTMLTags(@Description)  --added by Ronak 081021  
 If @tran_type  = 'I'  
  Begin  
    If Exists(Select Rating_ID From T0040_RATING_MASTER  WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and upper(Title) = upper(@Title))   
     begin     
      set @Rating_ID = 0  
      Return   
     end  
      
    select @Rating_ID= Isnull(max(Rating_ID),0) + 1 From T0040_RATING_MASTER WITH (NOLOCK)  
               
    if @Title  <> ''  
      Begin   
    INSERT INTO T0040_RATING_MASTER(Rating_ID, Cmp_ID, Title,Description,From_Rate,To_Rate)  
    VALUES (@Rating_ID, @Cmp_ID,@Title,@Description,@From_Rate,@To_Rate)  
      End       
  End  
 Else if @Tran_Type = 'U'  
  begin  
    If Exists(Select Rating_ID From T0040_RATING_MASTER  WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Rating_ID <> @Rating_ID and upper(Title) = upper(@Title))   
     begin  
      set @Rating_ID = 0  
      Return   
     end  
     
    Update T0040_RATING_MASTER  
    set Title=@Title  
        ,Description=@Description   
        ,From_Rate=@From_Rate  
        ,To_Rate=@To_Rate        
    where Rating_ID= @Rating_ID  
      
  end  
 Else if @Tran_Type = 'D'  
  begin  
   Delete From T0040_RATING_MASTER Where Rating_ID= @Rating_ID  
  end  
 RETURN  
  
  
  
  