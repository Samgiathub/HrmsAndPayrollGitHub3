  
  
  
  
CREATE PROCEDURE [dbo].[P0040_PROJECT_MASTER]  
   @Prj_ID numeric(18) output  
  ,@Prj_Name varchar(255)  
  ,@Cmp_ID numeric(18,0)  
  ,@Prj_Group varchar(100)  
  ,@Prj_Price numeric(18,0)  
  ,@tran_type char  
  ,@User_Id numeric(18,0) = 0  
     ,@IP_Address varchar(30)= ''  
    
AS  
  
  SET NOCOUNT ON   
  SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
  SET ARITHABORT ON  
  
declare @OldValue as  varchar(max)  
declare @OldPrj_Name as varchar(255)  
declare @OldPrj_Group  as varchar(100)  
declare @OldPrj_Price as varchar(18)  
  
set @OldValue = ''  
set @OldPrj_Name = ''  
set @OldPrj_Group = ''  
set @OldPrj_Price = ''  
   set @Prj_Name = dbo.fnc_ReverseHTMLTags(@Prj_Name)  --added by Ronak 081021
 if upper(@tran_type) ='I'   
  begin  
    
   if exists (Select Prj_ID  from T0040_Project_Master WITH (NOLOCK) Where Upper(Prj_Name) = Upper(@Prj_Name) and Cmp_ID = @Cmp_ID)  -- Changed By Gadriwala 19032014 (add Condition Company wise)  
    begin  
     set @Prj_ID=0  
     return  
    end  
     select @Prj_ID = isnull(max(Prj_ID),0)+1 from T0040_Project_Master WITH (NOLOCK)  
        
     insert into T0040_Project_Master(Prj_ID,Prj_Name,Cmp_ID,Prj_Group,Prj_Price) values(@Prj_ID,@Prj_Name,@Cmp_ID,@Prj_Group,@Prj_Price)  
       
     set @OldValue = 'New Value' + '#'+ 'Project Name :' +ISNULL( @Prj_Name,'') + '#' + 'Project Group :' + ISNULL( @Prj_Group,'') + '#' + 'Project Price :' + CAST(ISNULL(@Prj_Price,0) AS VARCHAR(18)) + '#'   
       
  end   
 else if upper(@tran_type) ='U'   
  begin  
   if exists (Select Prj_ID  from T0040_Project_Master WITH (NOLOCK) Where Upper(Prj_Name )= upper(@Prj_Name) and Prj_ID <> @Prj_ID)   
    begin  
     set @Prj_ID=0  
     return  
    end     
    select @OldPrj_Name  =ISNULL(Prj_name,'') ,@OldPrj_Group  =ISNULL(Prj_Group,''),@OldPrj_Price  =isnull(Prj_Price,0) From dbo.T0040_Project_Master WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Prj_ID = @Prj_ID    
     Update T0040_Project_Master Set Prj_Name = @Prj_Name where Prj_ID = @Prj_ID and Cmp_ID = @Cmp_ID   
       
       set @OldValue = 'old Value' + '#'+ 'Project Name :' + @OldPrj_Name  + '#' + 'Project Group :' + @OldPrj_Group  + '#' + 'Project Prices :' + @OldPrj_Price + '#' +  
                                    + 'New Value' + '#'+ 'Project Name  :' +ISNULL(@Prj_Name,'') + '#' + 'Project Group :' + ISNULL( @Prj_Group,'') + '#' + 'Project Prices :' + CAST(ISNULL(@Prj_Price,0) AS VARCHAR(20)) + '#'  
  
  end   
 else if upper(@tran_type)='D'  
  Begin   
 select @OldPrj_Name  = Prj_Name ,@OldPrj_Group  =Prj_Group,@OldPrj_Price  =isnull(Prj_Price,'') From dbo.T0040_Project_Master WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Prj_ID = @Prj_ID  
   
   delete  from T0040_Project_Master where Prj_ID=@Prj_ID   
     
   set @OldValue = 'old Value' + '#'+ 'Project Name :' + @OldPrj_Name  + '#' + 'Project Group :' + @OldPrj_Group  + '#' + 'Project Prices :' + @OldPrj_Price   
     
   end  
     
    exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'Project Master',@OldValue,@Prj_ID,@User_Id,@IP_Address  
     
     
  
 RETURN  
  
  
  
  