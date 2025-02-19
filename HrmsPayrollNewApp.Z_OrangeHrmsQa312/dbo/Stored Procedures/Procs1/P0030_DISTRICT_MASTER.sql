
CREATE PROCEDURE [dbo].[P0030_DISTRICT_MASTER]  
 @Dist_ID AS NUMERIC output,  
@Dist_NAME AS VARCHAR(100),  
 @CMP_ID AS NUMERIC(18,0),  
 @State_ID as numeric,  
 @Country_ID as numeric,  
 @tran_type varchar(1)  
   
AS  
SET NOCOUNT ON   
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
SET ARITHABORT ON  


set @Dist_NAME = dbo.fnc_ReverseHTMLTags(@Dist_NAME)  

   
 If @tran_type  = 'I'  
  Begin  
  if not Exists(select State_ID from T0020_STATE_MASTER WITH (NOLOCK) where State_ID=@State_ID and Loc_ID=@Country_ID and Cmp_ID=@Cmp_ID)  
     BEGIN  
      set @Dist_ID = 0  
      RAISERROR ('@@State is not Exists in selected Country@@' , 16, 2)  
      RETURN;  
     END 
  
    If Exists(Select Dist_ID From T0030_DISTRICT_MASTER WITH (NOLOCK)  Where Cmp_ID = @Cmp_ID and upper(Dist_Name) = upper(@Dist_NAME) and State_ID=@State_ID )  
     begin       
      set @Dist_ID = 0  
      Return   
     end  
      
      
    select @Dist_ID = Isnull(max(Dist_ID),0) + 1  From T0030_DISTRICT_MASTER WITH (NOLOCK)  
        
        
    INSERT INTO T0030_DISTRICT_MASTER  
                          (Dist_ID,State_id,Loc_ID,Dist_Name,Cmp_ID)  
    VALUES     (@Dist_ID,@State_ID,@Country_ID,@Dist_NAME,@CMP_ID)  
      
      
      
  End  
 Else if @Tran_Type = 'U'  
  begin  
  if not Exists(select State_ID from T0020_STATE_MASTER WITH (NOLOCK) where State_ID=@State_ID and Loc_ID=@Country_ID and Cmp_ID=@Cmp_ID)  
     BEGIN  
      set @Dist_ID = 0  
      RAISERROR ('@@State is not Exists in selected Country@@' , 16, 2)  
      RETURN;  
     END 

	 --and upper(Dist_Name) = upper(@Dist_NAME)
  
    If Exists(Select Dist_ID From T0030_DISTRICT_MASTER WITH (NOLOCK)  Where Cmp_ID = @Cmp_ID and upper(Dist_Name) = upper(@Dist_NAME) and Dist_ID <> @Dist_ID)   
     begin  
      set @Dist_ID = 0  
      Return   
     end  
       
                
    Update T0030_DISTRICT_MASTER  
    set Dist_Name = @Dist_NAME,   
     State_id=@State_ID,  
     Loc_ID=@Country_ID               
    where Dist_ID = @Dist_ID and Cmp_ID=@Cmp_ID  
      
  end  
 Else if @Tran_Type = 'D'  
  begin  

    if Exists(select T_ID  from T0030_TEHSIL_MASTER where Cmp_ID=@CMP_ID and Dist_ID=@Dist_ID)  
     begin  
	  set @Dist_ID = 0  
      --RAISERROR('@@ Reference Esits @@',16,2)  
      RETURN   
     end  

	 

    Delete From T0030_DISTRICT_MASTER Where Dist_ID=@Dist_ID and Cmp_ID=@CMP_ID      
      
  end   
  
 RETURN  