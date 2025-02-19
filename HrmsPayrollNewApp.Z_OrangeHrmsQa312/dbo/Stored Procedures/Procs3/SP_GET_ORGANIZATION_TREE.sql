




-- =============================================  
-- Author:  zalak shah  
-- ALTER date: 5 Oct 2010  
-- Description: <for Designation chart at user> 
---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================  
CREATE PROCEDURE [dbo].[SP_GET_ORGANIZATION_TREE]    
   
 @cmp_id as numeric,  
 @branch_id as NUMERIC,  
 @emp_id as NUMERIC,  
 @int_level as NUMERIC,  
 @MaxLevel as NUMERIC  
  
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

 BEGIN  
  if @branch_id = 0  
   set @branch_id = null  
        if @emp_id = 0   
   set @emp_id= null  
  
  declare @Row_No numeric  


    
  if @int_level = 0    
   begin  
    set @Row_No = 0  
    set @Int_Level= 0  
    select @Row_No = isnull(max(Row_Id), 0) + 1 from TBL_ORGANIZATION_DISPLAY WITH (NOLOCK) 
    if isnull(@emp_id,0) <> 0  
    begin  
     Insert Into TBL_ORGANIZATION_DISPLAY  
     (Row_Id,Emp_id,Emp_name,Desig_id,Def_id,Int_level,Parent_id,Total_Member,Is_main)  
     SELECT @Row_No, emp_id,cast(Alpha_Emp_Code as varchar(50)) + ' - ' + Emp_full_name + '<b> (' + Desig_name + ')<b/> ',desig_id,Def_id,@Int_Level,Parent_id,0,Is_main FROM V0080_Employee_master WHERE cmp_id=@cmp_id and branch_id=isnull(@branch_id,branch_id) and emp_id = @emp_id and emp_left<>'Y'   

--select * from TBL_ORGANIZATION_DISPLAY
     end  
                else if isnull(@branch_id,0)<>0   
     begin  
     Insert Into TBL_ORGANIZATION_DISPLAY  
     (Row_Id,Emp_id,Emp_name,Desig_id,Def_id,Int_level,Parent_id,Total_Member,is_main)  
     SELECT @Row_No,emp_id,cast(Alpha_Emp_Code as varchar(50)) + ' - ' + Emp_full_name + ' <b> (' + Desig_name + ')</b> ',desig_id,Def_id,@Int_Level,Parent_id,0,Is_main FROM V0080_Employee_master WHERE cmp_id=@cmp_id and branch_id=isnull(@branch_id,branch_id) and Is_main=1 and emp_left<>'Y'  
  
     SELECT @emp_id=emp_id FROM V0080_Employee_master WHERE cmp_id=@cmp_id and branch_id=isnull(@branch_id,branch_id) and Is_main=1 and emp_left<>'Y'  
     end  
    else  
     begin  
     Insert Into TBL_ORGANIZATION_DISPLAY  
     (Row_Id,Emp_id,Emp_name,Desig_id,Def_id,Int_level,Parent_id,Total_Member,is_main)  
     SELECT @Row_No,emp_id,cast(Alpha_Emp_Code as varchar(50)) + ' - ' + Emp_full_name + ' <b>(' + Desig_name + ')</b> ',desig_id,Def_id,@Int_Level,Parent_id,0,Is_main FROM V0080_Employee_master WHERE cmp_id=@cmp_id and isnull(Parent_id,0)=0 and Is_main=1 and emp_left<>'Y'  
  
     SELECT @emp_id=emp_id FROM V0080_Employee_master WHERE cmp_id=@cmp_id and isnull(Parent_id,0)=0 and Is_main=1 and emp_left<>'Y'  
     end  
   end  
     


  set @Int_Level= @Int_Level + 1  
    
  --select * from TBL_ORGANIZATION_DISPLAY  
  if @Int_Level = @MaxLevel   
   begin  
    return  
   end  
  Declare @Emp_id1 numeric(18, 0)   
  Declare @Emp_name varchar(500)   
  Declare @Desig_id numeric(18, 0)   
  Declare @Def_id  numeric(18, 0)   
  Declare @Parent_id numeric(18, 0)  
  declare @Is_main numeric(18, 0)  
  

      
  Declare curUser cursor Local for   
  SELECT Emp_id,cast(Alpha_Emp_Code as varchar(50)) + ' - ' + Emp_full_name + ' <b>(' + Desig_name + ')</b> ',Desig_id,Def_id,Parent_id,is_main  
--<br> Branch Name : ' + isnull(branch_name,'')  + '<br> Grade Name : ' + isnull(grd_name,'') + ' <br> Deparment : ' + isnull(dept_name,'nt assigned')  
  FROM V0080_Employee_master   
  WHERE cmp_id=@cmp_id and branch_id=isnull(@branch_id,branch_id) and emp_superior = @emp_id and emp_left<>'Y' order by emp_full_name  
     
   open curUser  
     
   Fetch next from curUser Into @Emp_id1, @Emp_name, @Desig_id,@Def_id,@Parent_id,@Is_main  
   while @@Fetch_Status = 0  
    begin  
     select @Row_No = isnull(max(Row_Id), 0) + 1 from TBL_ORGANIZATION_DISPLAY WITH (NOLOCK)  
	
     Insert Into TBL_ORGANIZATION_DISPLAY   
     (Row_Id,Emp_id,Emp_name,Desig_id,Def_id,Int_level,Parent_id,Total_Member,Is_main)  
     values   
     (@Row_No,@Emp_id1,@Emp_name,@Desig_id,@Def_id,@Int_Level,@Parent_id,0,@Is_main)  
    
     Exec SP_GET_ORGANIZATION_TREE @cmp_id,@branch_id,@emp_id1,@int_level,@MaxLevel   
         
    Fetch next from curUser Into @Emp_id1, @Emp_name, @Desig_id,@Def_id,@Parent_id,@Is_main  
    End  
  
   Close curUser  
   Deallocate curUser  
 RETURN  
END  




