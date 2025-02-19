  
---20/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---  
CREATE  PROCEDURE [dbo].[Sp_Location_Master]  
   @Loc_ID numeric(18) output  
  ,@Loc_Name varchar(255)  
  ,@Cmp_ID numeric(18,0)=0  
  ,@tran_type char  
  ,@User_Id numeric(18,0) = 0 --Add By Paras 15-10-2012  
     ,@IP_Address varchar(30)= '' --Add By Paras 15-10-2012  
     ,@Loc_Cat_ID numeric(18,0)=0 --Added by Sumit 25112015  
    
AS  
  
SET NOCOUNT ON   
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
SET ARITHABORT ON  
  
--Add By Paras 15-10-2012  
declare @OldValue as  varchar(max)  
Declare @OldLoc_Name as varchar(255)  
set @OldLoc_Name =''  
--Add By Paras 15-10-2012  
---Added by Sumit 25112015-------------------------------------  
if (@Loc_Cat_ID=0)  
 Begin  
  set @Loc_Cat_ID=null   
 End  
-------------------------------------------------------------  
 set @Loc_Name = dbo.fnc_ReverseHTMLTags(@Loc_Name)  --added by Ronak 081021
 if @tran_type ='i'  
  begin  
    
   if exists (Select Loc_ID  from T0001_Location_Master WITH (NOLOCK) Where Upper(Loc_Name) = Upper(@Loc_Name))   
    begin  
     set @Loc_ID=0  
     return  
    end  
   else  
    begin  
     select @Loc_ID = isnull(max(Loc_ID),0) +1  from T0001_Location_Master WITH (NOLOCK)  
        
     insert into T0001_Location_Master(Loc_ID,Loc_Name,Loc_cat_id) values(@Loc_ID,@Loc_Name,@Loc_Cat_ID)  
     --Add By PAras 12-10-2012  
      set @OldValue = 'New Value' + '#'+ 'Country Name :' +ISNULL( @Loc_Name,'') + '#'   
      ---  
    end  
  end   
 else if @tran_type ='U'   
  begin  
   if exists (Select Loc_ID  from T0001_Location_Master WITH (NOLOCK) Where Upper(Loc_Name )= upper(@Loc_Name) and Loc_ID <> @Loc_ID)   
    begin  
     set @Loc_ID=0  
    end       
   else  
    begin  
    --Add By paras 12-10-2012  
      select @OldLoc_Name  =ISNULL(Loc_name,'')  From dbo.T0001_Location_Master WITH (NOLOCK) Where Loc_ID = @Loc_ID   
     Update T0001_Location_Master Set Loc_Name = @Loc_Name,Loc_cat_id=@Loc_Cat_ID where Loc_ID = @Loc_ID   
       
     set @OldValue = 'old Value' + '#'+ 'Country Name:' + @OldLoc_Name  + '#'   
                       + 'New Value' + '#'+ 'Country Name :' +ISNULL( @Loc_name,'') + '#'   
                       ----  
  
    end  
  end   
 else if @tran_type ='D'  
  begin  
  --Add By Paras 12-10-2012  
   select @OldLoc_Name  = Loc_name  From dbo.T0001_Location_Master WITH (NOLOCK) Where  Loc_ID = @Loc_ID  
        
   delete  from T0001_Location_Master where Loc_ID=@Loc_ID   
   set @OldValue = 'old Value' + '#'+ 'Country Name :' + @OldLoc_Name  + '#'   
  End  
    exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'Country Master',@OldValue,@Loc_ID,@User_Id,@IP_Address  
  
 RETURN  
  
  
  
  