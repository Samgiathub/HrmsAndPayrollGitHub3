    
    
---13/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---    
CREATE PROCEDURE [dbo].[P0040_WARNING_MASTER]    
 @War_ID AS NUMERIC output,    
 @CMP_ID AS NUMERIC,    
 @War_Name AS VARCHAR(100),    
 @War_Comments AS VARCHAR(250),    
 @Deduct_Rate as numeric(18,2),    
 @Dedu_Type as VARCHAR(10), --Added By Ramiz on 24/07/2017    
 @tran_type as varchar(1)    
 ,@User_Id numeric(18,0) = 0    
    ,@IP_Address varchar(30)= '' --Add By Paras 18-10-2012    
    ,@Level_Id as numeric(18,0) = 0  -- Added by Jaina 12-03-2018    
AS    
SET NOCOUNT ON     
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED    
SET ARITHABORT ON    
    
declare @OldValue as varchar(Max)    
declare @OldWar_Name as varchar(100)    
declare @OldWar_Comments as varchar(100)    
declare @OldWar_Rate as varchar(18)    
declare @Old_Dedu_Type as Varchar(10)    
declare @Old_Level_ID as numeric(18,0)  --Added by Jaina 12-03-2018    
Declare @NewLevel_Name as varchar(50) = ''    
Declare @OldLevel_Name as varchar(50) = ''    
    
set @OldWar_Name = ''    
set @OldWar_Comments = ''    
set @OldWar_Rate =''    
set @Old_Dedu_Type = ''    
         set @War_Name = dbo.fnc_ReverseHTMLTags(@War_Name)  --added by mansi 061021
		  set @War_Comments = dbo.fnc_ReverseHTMLTags(@War_Comments)  --added by mansi 121021   

 If @tran_type  = 'I'    
  Begin    
   if exists(select War_ID from T0040_WARNING_MASTER WITH (NOLOCK) where upper(War_Name) = upper(@War_Name) and Cmp_ID = @Cmp_ID)    
    begin    
     set @War_ID = 0    
     Return     
    end    
    
    select @War_ID = Isnull(max(War_ID),0) + 1  From T0040_WARNING_MASTER WITH (NOLOCK)    
        
    INSERT INTO T0040_WARNING_MASTER    
                          (War_ID, Cmp_ID, War_Name,War_Comments,Deduct_Rate , Deduct_Type,Level_Id)    
    VALUES     (@War_ID, @Cmp_ID, @War_Name,@War_Comments,@Deduct_Rate , @Dedu_Type,@Level_ID)    
        
    --Added by Jaina 12-03-2018    
    Declare @Level_Name as varchar(50)    
    Select @Level_Name =Level_Name from T0040_Warning_CardMapping WITH (NOLOCK) where Cmp_id = @Cmp_Id and Level_ID = @Level_ID    
        
        
    set @OldValue = 'New Value' + '#'+ 'Warning Name :' +ISNULL( @War_Name,'') + '#' + 'Waring Comment :' + ISNULL( @War_Comments,'') + '#' + 'Warning Rate:' + CAST(ISNULL(@Deduct_Rate,0) AS VARCHAR(20)) + '#'  + 'Deduction Type:' + CAST(ISNULL(@Dedu_Type
  
,0) AS VARCHAR(20)) + '#' + 'Level:' + ISNULL(@Level_Name,'') + '#'    
  End    
 Else if @Tran_Type = 'U'    
    
  begin    
    If exists(select War_ID from T0040_WARNING_MASTER WITH (NOLOCK) where upper(War_Name) = upper(@War_Name) and War_ID <> @War_ID    
        and Cmp_ID = @Cmp_ID )    
     begin    
      set @War_ID = 0    
      Return     
     end    
         
    select @OldWar_Name =ISNULL(War_Name,'') ,    
      @OldWar_Comments  =ISNULL(War_Comments,''),    
      @OldWar_Rate  =CAST(isnull(Deduct_Rate,0)as varchar(20)),    
      @Old_Dedu_Type = ISNULL(Deduct_Type , ''),    
      @Old_Level_ID = isnull(Level_ID,0)    
    From dbo.T0040_WARNING_MASTER WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and War_ID = @War_ID     
          
        
    Update T0040_WARNING_MASTER    
    set War_Name = @War_Name ,War_Comments = @War_Comments,Deduct_Rate=@Deduct_Rate, Deduct_Type = @Dedu_Type    
    ,Level_Id = @Level_Id    
    where War_ID = @War_ID    
           
    --Added by Jaina 12-03-2018    
        
    Select @NewLevel_Name =Level_Name from T0040_Warning_CardMapping WITH (NOLOCK) where Cmp_id = @Cmp_Id and Level_ID = @Level_ID    
        
    Select @OldLevel_Name =Level_Name from T0040_Warning_CardMapping WITH (NOLOCK) where Cmp_id = @Cmp_Id and Level_ID = @Old_Level_ID    
        
    set @OldValue = 'old Value' + '#'+ 'Warning Name :' +ISNULL( @OldWar_Name,'') + '#' + 'Waring Comment :' + ISNULL( @OldWar_Comments,'') + '#' + 'Warning Rate:' + CAST(ISNULL(@OldWar_Rate,0) AS VARCHAR(20)) + '#'  + 'Deduction Type:' + CAST(ISNULL(@Old_Dedu_Type,0) AS VARCHAR(20)) + '#' + 'Level:' + ISNULL(@OldLevel_Name,'') + '#'     
               + 'New Value' + '#'+ 'Warning Name :' +ISNULL( @War_Name,'') + '#' + 'Waring Comment :' + ISNULL( @War_Comments,'') + '#' + 'Warning Rate:' + CAST(ISNULL(@Deduct_Rate,0) AS VARCHAR(20)) + '#'   + 'Deduction Type:' + CAST(ISNULL(@Dedu_Type,0
  
) AS VARCHAR(20)) + '#' + 'Level :' + ISNULL(@NewLevel_Name,'') + '#'     
        
                        
  End    
 Else if @Tran_Type = 'D'    
  begin    
   delete from T0050_Warning_Slab where warning_id = @War_ID and cmp_ID = @cmp_ID  -- Added by Gadriwala Muslim 14042015    
       
   select @OldWar_Name  =ISNULL(War_Name,'') ,    
     @OldWar_Comments  =ISNULL(War_Comments,''),    
     @OldWar_Rate  =CAST(isnull(Deduct_Rate,0)as varchar(10))  ,    
     @Old_Dedu_Type = ISNULL(Deduct_Type , ''),    
     @Old_Level_ID = isnull(Level_ID,0)    
   From dbo.T0040_WARNING_MASTER WITH (NOLOCK) Where Cmp_ID = @CMP_ID and War_ID = @War_ID     
        
   Select @OldLevel_Name =Level_Name from T0040_Warning_CardMapping WITH (NOLOCK) where Cmp_id = @Cmp_Id and Level_ID = @Old_Level_ID    
        
    Delete From T0040_WARNING_MASTER Where War_ID = @War_ID    
        
    set @OldValue = 'old Value' + '#'+ 'Warning Name :' +ISNULL( @OldWar_Name,'') + '#' + 'Waring Comment :' + ISNULL( @OldWar_Comments,'') + '#' + 'Warning Rate:' + CAST(ISNULL(@OldWar_Rate,0) AS VARCHAR(20)) + '#'  + 'Deduction Type:' + CAST(ISNULL(@Old_Dedu_Type,0) AS VARCHAR(20)) + '#'  + 'Level:' + ISNULL(@OldLevel_Name,'') + '#'     
  end    
  exec P9999_Audit_Trail @CMP_ID,@Tran_Type,'Warning Master',@OldValue,@War_ID,@User_Id,@IP_Address    
    
 RETURN    
    
    
    