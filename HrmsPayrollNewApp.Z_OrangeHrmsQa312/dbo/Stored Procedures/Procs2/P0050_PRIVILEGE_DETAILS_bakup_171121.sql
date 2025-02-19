  
  
---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---  
CREATE PROCEDURE [dbo].[P0050_PRIVILEGE_DETAILS_bakup_171121]  
 @Trans_Id as numeric output,  
 @Privilege_ID AS numeric,  
 @CMP_ID AS numeric,  
 @Form_Id as numeric,  
 @Is_View as tinyint,  
 @Is_Edit as tinyint,  
 @Is_Save as tinyint,  
 @Is_Delete as tinyint,  
 @tran_type varchar(1),  
 @Copy_From_PrivilegeID AS NUMERIC = 0,  --Mukti 27012016  
 @Privilege_CopyCompany_Id as numeric = 0  --Added by Jaina 01-03-2018  
AS  
SET NOCOUNT ON   
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
SET ARITHABORT ON  
   Print @tran_type
 If @tran_type  = 'I'  
  Begin  
    If Exists(Select Privilage_ID From T0050_PRIVILEGE_DETAILS WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Form_id = @Form_Id and Privilage_ID = @Privilege_ID )   
     begin  
      --UPDATE   T0050_PRIVILEGE_DETAILS  
      -- SET     Is_View = @Is_View, Is_Edit = @Is_Edit,   
      --   Is_Save = @Is_Save, Is_Delete = @Is_Delete, Is_Print = 0  
      -- where Privilage_ID = @Privilege_ID and Cmp_Id = @Cmp_Id and Form_Id = @Form_Id  
        
      Delete from T0050_PRIVILEGE_DETAILS  
       where Privilage_ID = @Privilege_ID and Cmp_Id = @Cmp_Id and Form_Id = @Form_Id  
     end  
    if (@Privilege_CopyCompany_Id > 0 and @Copy_From_PrivilegeID > 0 )  --Added by Jaina 01-03-2018  
    BEGIN  
       INSERT INTO T0050_PRIVILEGE_DETAILS   
       select  (select Isnull(max(Trans_Id),0) from T0050_PRIVILEGE_DETAILS WITH (NOLOCK))  + ROW_NUMBER() OVER (ORDER BY form_id) as Trans_Id,  
        @Privilege_ID as Privilege_ID,@Privilege_CopyCompany_Id as Cmp_Id,form_id,Is_View, Is_Edit, Is_Save, Is_Delete, Is_Print  
       from T0050_PRIVILEGE_DETAILS WITH (NOLOCK)  
       where Privilage_ID = @Copy_From_PrivilegeID   
    END        
    ELSE IF (@Copy_From_PrivilegeID > 0)--Mukti 27012016 (To copy details of existing Privilege)  
     begin  
       INSERT INTO T0050_PRIVILEGE_DETAILS   
       select  (select Isnull(max(Trans_Id),0) from T0050_PRIVILEGE_DETAILS WITH (NOLOCK))  + ROW_NUMBER() OVER (ORDER BY form_id) as Trans_Id,  
        @Privilege_ID as Privilege_ID,@cmp_id as Cmp_Id,form_id,Is_View, Is_Edit, Is_Save, Is_Delete, Is_Print  
       from T0050_PRIVILEGE_DETAILS WITH (NOLOCK)  
       where Privilage_ID = @Copy_From_PrivilegeID   
          
     end  
    ELSE  
     begin  
      select @Trans_Id = Isnull(max(Trans_Id),0) + 1  From T0050_PRIVILEGE_DETAILS  WITH (NOLOCK)  
         
      INSERT INTO T0050_PRIVILEGE_DETAILS  
         (Trans_Id, Privilage_ID, Cmp_Id, Form_Id, Is_View, Is_Edit, Is_Save, Is_Delete, Is_Print)  
      VALUES     (@Trans_Id,@Privilege_ID,@Cmp_Id,@Form_Id,@Is_View,@Is_Edit,@Is_Save,@Is_Delete,0)  
     END  
      
      
      
  End  
 --Else if @Tran_Type = 'U'  
 -- begin  
      
      
 --   UPDATE   T0050_PRIVILEGE_DETAILS  
 --   SET     Is_View = @Is_View, Is_Edit = @Is_Edit,   
 --     Is_Save = @Is_Save, Is_Delete = @Is_Delete, Is_Print = 0  
 --               where Privilage_ID = @Privilege_ID and Cmp_Id = @Cmp_Id and Form_Id = @Form_Id  
      
 -- end  
 --Else if @Tran_Type = 'D'  
 -- begin  
 --   Delete From T0050_PRIVILEGE_DETAILS Where Trans_ID = @Trans_Id  
 -- end  
  
 RETURN  
  
  
  
  