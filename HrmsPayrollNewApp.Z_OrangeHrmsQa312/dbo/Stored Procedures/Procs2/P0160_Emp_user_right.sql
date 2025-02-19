



---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0160_Emp_user_right]  
  @Login_ID  numeric  
 ,@cmp_ID    numeric  
AS  

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

 if @Login_ID = 0  
   set @Login_ID=null  
     
 Declare @M_Branch_ID numeric   
 
 Declare @Data Table  
  (   
    
   Login_Id numeric ,  
   cmp_ID  numeric ,  
   Form_ID  numeric ,  
   Branch_ID   numeric default 0,  
   Is_save  numeric default 0,  
   Is_Delete numeric default 0,  
   Is_Edit  numeric default 0,  
   IS_View  numeric default 0,  
   Is_Print numeric default 0  
  )   
  
  
 Select @M_Branch_ID = Branch_ID from T0011_Login WITH (NOLOCK) where Login_ID=@Login_ID  
   
 insert into @Data (login_ID,Cmp_ID,Form_ID,Branch_ID)  
  
 select @Login_ID ,@cmp_ID ,a.Form_ID,b.Branch_ID from T0000_Default_Form  a WITH (NOLOCK)
 left outer join t0015_Login_Branch_rights b WITH (NOLOCK) on b.Login_ID = @Login_Id    where  a.Form_ID >= 5000  
   
  --Select * from @Data  
  
 if isnull(@Login_ID,0) > 0  
  begin  
   Update @Data  
   set Is_Save = lfr.Is_SAve ,  
    Is_Edit = lfr.Is_Edit ,  
    Is_Delete = lfr.Is_Delete,  
    is_View = lfr.Is_View,  
    Is_PRint = lfr.IS_Print  
     
   From @Data d inner join T0015_Login_Form_Rights lfr WITH (NOLOCK) on d.Form_ID =lfr.Form_ID  
   where lfr.Login_ID =@Login_ID  
  end   
  --Select * from T0015_Login_Form_Rights
 --select * from @Data   
   
   
 Select * ,@M_Branch_ID M_Branch_ID  from(  
  
Select a.Form_ID,'--'+ Form_name +'--' as Form_name,LR.Is_Save,LR.Is_Edit,LR.Is_Delete,LR.Is_View,LR.Branch_ID,Under_form_ID   
 From T0000_Default_Form  a  WITH (NOLOCK)   inner  join  @Data LR on a.Form_ID =LR.Form_ID  
    where a.Under_Form_ID=0   
union all  
  
  
Select  b.Form_ID,'>>'+ Form_name,LR.Is_Save,LR.Is_Edit,LR.Is_Delete,LR.Is_View,LR.Branch_ID,Under_Form_ID from  
 T0000_Default_Form as   
 b WITH (NOLOCK) inner  join  @Data LR on b.Form_ID =LR.Form_ID and b.Under_Form_ID<>0 
 -- and b.Form_ID < 5004   /*this line added by mihir for temporary make functionality to disable HRMS form 01/07/2011*/
 
   
    
)   as data order by  Form_ID   
   
RETURN  
  
  


