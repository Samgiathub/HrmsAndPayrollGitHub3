  
---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---  
CREATE PROCEDURE [dbo].[P0030_CITY_MASTER]  
 @City_ID AS NUMERIC output,  
 @City_NAME AS VARCHAR(100),  
 @CMP_ID AS NUMERIC(18,0),  
 @City_Cat_ID as numeric,  
 @State_ID as numeric,  
 @Country_ID as numeric,  
 @Remarks as varchar(200),  
 @tran_type varchar(1)  
   
AS  
SET NOCOUNT ON   
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
SET ARITHABORT ON  
set @City_NAME = dbo.fnc_ReverseHTMLTags(@City_NAME)  
    set @Remarks = dbo.fnc_ReverseHTMLTags(@Remarks)  

   
 If @tran_type  = 'I'  
  Begin  
  if not Exists(select State_ID from T0020_STATE_MASTER WITH (NOLOCK) where State_ID=@State_ID and Loc_ID=@Country_ID and Cmp_ID=@Cmp_ID)  
     BEGIN  
      set @City_ID = 0  
      RAISERROR ('@@State is not Exists in selected Country@@' , 16, 2)  
      RETURN;  
     END --Added by Sumit on 04082016 for getting location wise state and city map   
  
    If Exists(Select City_ID From T0030_CITY_MASTER WITH (NOLOCK)  Where Cmp_ID = @Cmp_ID and upper(City_Name) = upper(@City_NAME) AND City_cat_ID = @City_Cat_ID) --   
     begin       
      set @City_ID = 0  
      Return   
     end  
      
      
    select @City_ID = Isnull(max(City_ID),0) + 1  From T0030_CITY_MASTER WITH (NOLOCK)  
        
        
    INSERT INTO T0030_CITY_MASTER  
                          (City_ID,State_id,Loc_ID,City_cat_ID,City_Name,Remarks,Cmp_ID)  
    VALUES     (@City_ID,@State_ID,@Country_ID,@City_Cat_ID,@City_NAME,@Remarks,@CMP_ID)  
      
      
      
  End  
 Else if @Tran_Type = 'U'  
  begin  
  if not Exists(select State_ID from T0020_STATE_MASTER WITH (NOLOCK) where State_ID=@State_ID and Loc_ID=@Country_ID and Cmp_ID=@Cmp_ID)  
     BEGIN  
      set @City_ID = 0  
      RAISERROR ('@@State is not Exists in selected Country@@' , 16, 2)  
      RETURN;  
     END --Added by Sumit on 04082016 for getting location wise state and city map   
  
    If Exists(Select City_ID From T0030_CITY_MASTER WITH (NOLOCK)  Where Cmp_ID = @Cmp_ID and upper(City_Name) = upper(@City_NAME) AND City_cat_ID = @City_Cat_ID  and City_ID <> @City_ID) -- Modified by Mitesh 04/08/2011 for different collation db.  
     begin  
      set @City_ID = 0  
      Return   
     end  
       
                
    Update T0030_CITY_MASTER  
    set City_Name = @City_NAME,  
     City_cat_ID=@City_Cat_ID,  
     State_id=@State_ID,  
     Loc_ID=@Country_ID,          
        Remarks=@remarks                  
    where City_ID = @City_ID and Cmp_ID=@Cmp_ID  
      
  end  
 Else if @Tran_Type = 'D'  
  begin  
    if Exists(select City_ID from t0110_TRAVEL_APPLICATION_DETAIL WITH (NOLOCK) where Cmp_ID=@CMP_ID and City_ID=@City_ID)  
     begin  
      RAISERROR('@@ Reference Esits @@',16,2)  
      RETURN   
     end  
    Delete From T0030_CITY_MASTER Where City_ID=@City_ID and Cmp_ID=@CMP_ID      
      
  end   
  
 RETURN  