
CREATE PROCEDURE [dbo].[P0030_TEHSIL_MASTER]  
 @T_ID AS NUMERIC output,  
 @T_NAME AS VARCHAR(100),  
 @CMP_ID AS NUMERIC(18,0),  
 @State_ID as numeric,
 @D_ID as numeric,
 @Country_ID as numeric,  
 @tran_type varchar(1)  
   
AS  
SET NOCOUNT ON   
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
SET ARITHABORT ON  


set @T_NAME = dbo.fnc_ReverseHTMLTags(@T_NAME)  

   
 If @tran_type  = 'I'  
  Begin  
  
  if not Exists(select State_ID from T0020_STATE_MASTER WITH (NOLOCK) where State_ID=@State_ID and Loc_ID=@Country_ID and Cmp_ID=@Cmp_ID)  
     BEGIN  
      set @T_ID = 0  
      RAISERROR ('@@State is not Exists in selected Country@@' , 16, 2)  
      RETURN;  
     END 
   
   if not Exists(select Dist_ID from T0030_DISTRICT_MASTER WITH (NOLOCK) where Dist_ID=@D_ID and Loc_ID=@Country_ID and Cmp_ID=@Cmp_ID)  
     BEGIN  
      set @T_ID = 0  
      RAISERROR ('@@District is not Exists in selected Country@@' , 16, 2)  
      RETURN;  
     END 



    If Exists(Select T_ID From T0030_TEHSIL_MASTER WITH (NOLOCK)  Where Cmp_ID = @Cmp_ID and upper(T_Name) = upper(@T_NAME) and State_ID=@State_ID and Dist_ID=@D_ID )  
     begin       
      set @T_ID = 0  
      Return   
     end  
      
      
    select @T_ID = Isnull(max(T_ID),0) + 1  From T0030_TEHSIL_MASTER WITH (NOLOCK)  
        
        
    INSERT INTO T0030_TEHSIL_MASTER (T_ID,State_id,Loc_ID,T_Name,Cmp_ID,Dist_ID)  
    VALUES     (@T_ID,@State_ID,@Country_ID,@T_NAME,@CMP_ID,@D_ID)  
      
      
      
  End  
 Else if @Tran_Type = 'U'  
  begin  
  if not Exists(select State_ID from T0020_STATE_MASTER WITH (NOLOCK) where State_ID=@State_ID and Loc_ID=@Country_ID and Cmp_ID=@Cmp_ID)  
     BEGIN  
      set @T_ID = 0  
      RAISERROR ('@@State is not Exists in selected Country@@' , 16, 2)  
      RETURN;  
     END 

	 --and upper(Dist_Name) = upper(@T_NAME)
  
    If Exists(Select T_ID From T0030_TEHSIL_MASTER WITH (NOLOCK)  Where Cmp_ID = @Cmp_ID and upper(T_Name) = upper(@T_NAME) and  Dist_ID=@D_ID and T_ID <> @T_ID)   
     begin  
      set @T_ID = 0  
      Return   
     end  
       
                
    Update T0030_TEHSIL_MASTER  
    set T_Name = @T_NAME,   
     State_id=@State_ID,
	 Dist_ID=@D_ID,
     Loc_ID=@Country_ID               
    where T_ID = @T_ID and Cmp_ID=@Cmp_ID  
      
  end  
 Else if @Tran_Type = 'D'  
  begin  

    if Exists(select Branch_ID from T0030_BRANCH_MASTER where Cmp_ID=@CMP_ID and Tehsil_ID=@T_ID)  
     begin
	  set @T_ID = 0  
      --RAISERROR('@@ Reference Esits @@',16,2)  
      RETURN   
     end  


    Delete From T0030_TEHSIL_MASTER Where T_ID=@T_ID and Cmp_ID=@CMP_ID      
      
  end   
  
 RETURN  