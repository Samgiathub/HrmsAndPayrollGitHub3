  
  
-- =============================================  
-- Author:  <Jaina>  
-- Create date: <02-06-2016>  
-- Description: <Clearance Attribute for Exit Module>  
---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---  
-- =============================================  
CREATE PROCEDURE [dbo].[P0040_Clearance_Attribute]   
 @Clearance_id numeric(18,0) output,  
 @Cmp_id numeric(18,0),  
 @Dept_id varchar(max) = '',--Mukti(10072018)  
 @Cost_Center_ID varchar(max) = '',--Mukti(30072018)  
 @Item_code varchar(50),  
 @Item_Name varchar(500),  
 @Active tinyint,  
 @Tran_Type varchar(1)='',  
 @User_Id numeric(18,0) = 0,  
    @IP_Address varchar(30)= ''   
   
   
AS  
  
SET NOCOUNT ON   
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
SET ARITHABORT ON  
  
BEGIN  
  
Declare @OldValue As varchar(max)  
Declare @OldDepartment As varchar(500)  
Declare @NewDepartment As varchar(500)  
Declare @OldItem_code As varchar(50)  
Declare @OldItem_Name As varchar(500)  
Declare @OldActive As varchar(10)  
Declare @NewActive As varchar(10)  
DECLARE @Clearance_Dept as INT  
DECLARE @CostCenter as VARCHAR(500)  
  
set @OldActive =''  
set @OldDepartment = ''  
set @OldItem_code = ''  
set @OldItem_Name = ''  
set @OldValue = ''  
set @NewDepartment = ''  
set @NewActive = ''  
   set @Item_Name = dbo.fnc_ReverseHTMLTags(@Item_Name)  --added by Ronak 081021
if isnull(@Tran_Type,'') = 'I'  
Begin  
 --(Upper(Item_Code) = Upper(@Item_code) OR   
   
 IF @Dept_id <> ''  
  BEGIN  
    DECLARE Clearance_Dept CURSOR FOR SELECT CAST(Data as numeric(18,0))  FROM dbo.Split(@Dept_id,'#') where Data > 0  
    OPEN Clearance_Dept   
      fetch next from Clearance_Dept into @Clearance_Dept  
    while @@fetch_status = 0  
     Begin     
       SELECT @CLEARANCE_ID = ISNULL(MAX(CLEARANCE_ID),0)+ 1 FROM T0040_CLEARANCE_ATTRIBUTE WITH (NOLOCK)  
          
       INSERT INTO T0040_Clearance_Attribute (Clearance_id,Cmp_id,Dept_id,Cost_Center_ID,Item_Code,Item_Name,Active)   
       VALUES (@Clearance_id,@Cmp_id,@Clearance_Dept,NULL,@Item_code,@Item_Name,@Active)  
         
       fetch next from Clearance_Dept into @Clearance_Dept  
     End  
    Close Clearance_Dept   
    deallocate Clearance_Dept  
  END  
   
 IF @Cost_Center_ID <> ''  
  BEGIN  
   DECLARE Clearance_CostCenter CURSOR FOR SELECT CAST(Data as numeric(18,0))  FROM dbo.Split(@Cost_Center_ID,'#') where Data > 0  
    OPEN Clearance_CostCenter   
      fetch next from Clearance_CostCenter into @CostCenter  
    while @@fetch_status = 0  
     Begin    
       if exists (Select Clearance_id  from T0040_Clearance_Attribute WITH (NOLOCK) Where  Upper(Item_Name) = Upper(@Item_Name) and Cost_Center_ID=@CostCenter  and Cmp_ID = @Cmp_ID)   
       begin  
        set @Clearance_id = 0  
        Return   
       end   
         
       SELECT @CLEARANCE_ID = ISNULL(MAX(CLEARANCE_ID),0)+ 1 FROM T0040_CLEARANCE_ATTRIBUTE WITH (NOLOCK)  
          
       INSERT INTO T0040_Clearance_Attribute (Clearance_id,Cmp_id,Dept_id,Cost_Center_ID,Item_Code,Item_Name,Active)   
       VALUES (@Clearance_id,@Cmp_id,NULL,@CostCenter,@Item_code,@Item_Name,@Active)  
         
       fetch next from Clearance_CostCenter into @CostCenter  
     End  
    Close Clearance_CostCenter   
    deallocate Clearance_CostCenter  
  END  
    
 If @Active = 1   
  set @NewActive = 'YES'  
 Else  
  set @NewActive = 'NO'  
        
 --select @NewDepartment = Dept_Name from T0040_DEPARTMENT_MASTER where Dept_Id = @Dept_id  
         
 --set @OldValue = 'New Value' + '#' + 'Department Name :' + ISNULL(@NewDepartment,'') +   
 --         --'#' + 'Item Code :' + ISNULL(@Item_code ,'') +   
 --         '#' + 'Item Name :' + ISNULL(@Item_Name,'')+   
 --         '#' + 'Is Active :' + ISNULL(@NewActive,'')+ '#'   
               
     
End  
  
if isnull(@Tran_Type,'') = 'U'  
Begin  
 if @Dept_id=''  
  set @Dept_id=null  
 if @cost_center_id=''  
  set @cost_center_id=null  
 --upper(Item_Code) = upper(@Item_code) and  
 --Comment by Jaina 01-09-2018  
 --IF Exists(select Clearance_id From dbo.T0040_Clearance_Attribute Where Upper(Item_Name) = Upper(@Item_Name)AND  Cmp_ID = @Cmp_ID and Clearance_id <> @Clearance_id)    
 --   Begin    
 --  print 1  
 --    set @Clearance_id = 0    
 --    Return     
 --   End    
   
 select @OldDepartment = ( SELECT DM.Dept_Name FROM T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) WHERE DM.Dept_Id = CA.Dept_id),  
     @OldItem_code = Item_code,  
     @OldItem_Name = Item_name,  
     @OldActive = Active  
 from T0040_Clearance_Attribute As CA WITH (NOLOCK)  
 where Cmp_id= @Cmp_id and Clearance_id = @Clearance_id  
   
   
 update T0040_Clearance_Attribute   
  set Dept_id = @Dept_id,  
   Item_code = @Item_code,  
   Item_name = @Item_Name,  
   Active = @Active,  
   cost_center_id=@cost_center_id  
  where Clearance_id = @Clearance_id and Cmp_id = @Cmp_id  
   
 If @Active = 1   
  set @NewActive = 'YES'  
 Else  
  set @NewActive = 'NO'  
    
 select @NewDepartment = Dept_Name from T0040_DEPARTMENT_MASTER WITH (NOLOCK) where Dept_Id = @Dept_id and Cmp_Id = @Cmp_id  
   
 set @OldValue = 'Old Value' + '#' + 'Department Name :' + ISNULL(@OldDepartment,'') +   
          --'#' + 'Item Code :' + ISNULL(@OldItem_code ,'') +   
          '#' + 'Item Name :' + ISNULL(@OldItem_Name,'')+   
          '#' + 'Is Active :' + case when isnull(@OldActive,0) = 1 then 'YES' ELSE 'NO' end + '#' +  
     'New Value' + '#' + 'Department Name :' + ISNULL(@NewDepartment,'') +   
          --'#' + 'Item Code :' + ISNULL(@Item_code ,'') +   
          '#' + 'Item Name :' + ISNULL(@Item_Name,'')+   
          '#' + 'Is Active :' + ISNULL(@NewActive,'')+ '#'   
End  
  
if isnull(@Tran_Type,'') = 'D'  
Begin  
   
 IF EXISTS (SELECT 1 FROM T0040_Clearance_Attribute C WITH (NOLOCK) INNER JOIN T0350_Exit_Clearance_Approval_Detail EA WITH (NOLOCK) ON C.Clearance_id = EA.Clearance_id WHERE C.Clearance_id = @Clearance_id)  
 BEGIN  
   --SET @Tran_Id = 0  
   RAISERROR ('Cannot Delete as Reference Exists', 16, 2)   
   RETURN   
 END  
    
 select @OldDepartment = ( SELECT DM.Dept_Name FROM T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) WHERE DM.Dept_Id = CA.Dept_id),  
     @OldItem_code = Item_code,  
     @OldItem_Name = Item_name,  
     @OldActive = Active  
 from T0040_Clearance_Attribute As CA WITH (NOLOCK)  
 where Cmp_id= @Cmp_id and Clearance_id = @Clearance_id  
   
 DELETE FROM T0040_Clearance_Attribute where Clearance_id = @Clearance_id and Cmp_id = @Cmp_id  
   
 set @OldValue = 'Old Value' + '#' + 'Department Name :' + ISNULL(@OldDepartment,'') +   
         -- '#' + 'Item Code :' + ISNULL(@OldItem_code ,'') +   
          '#' + 'Item Name :' + ISNULL(@OldItem_Name,'')+   
          '#' + 'Is Active :' + case when isnull(@OldActive,0) = 1 then 'YES' ELSE 'NO' end + '#'   
End  
  
exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'Clearance Attribute Master',@OldValue,@Clearance_id,@User_Id,@IP_Address   
  
END  
  