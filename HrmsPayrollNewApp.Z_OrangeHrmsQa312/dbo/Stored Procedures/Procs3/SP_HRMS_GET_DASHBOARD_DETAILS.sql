



---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_HRMS_GET_DASHBOARD_DETAILS]  
  @Cmp_ID numeric(18,0)  
 ,@Rec_Post_ID numeric(18,0)  
 ,@Resume_Status numeric(1,0)  
  
AS  
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

 if @Rec_Post_ID = 0  
   set @Rec_Post_ID = null  
  
   
      
   Declare @dash table  
   (  
      Resume_ID numeric(18,0),  
      Job_Title  Varchar(50),  
      App_Full_name varchar(50),  
      App_First_name varchar(50),
      Total_Exp numeric(18,2),  
      Gender varchar(10),  
      Resume_Status numeric(1,0)  
   )  
     
   Declare @Dahs_HRMS table
   (
       Resume_ID numeric(18,0),
       Resume_Status numeric(1,0)
       
   )  
     
   if @Resume_Status = 0  
     Begin   
  
  Insert into @dash (Resume_ID,Job_Title,App_Full_name,App_First_name,Total_Exp,Gender,Resume_Status)  
  Select Rm.Resume_Id,RP.Job_Title,(RM.Emp_First_name + ' - ' + RM.Emp_Last_name) as Emp_first_name ,Rm.Emp_First_name,RM.Total_Exp,RM.Gender,RM.Resume_Status   
   from T0055_Resume_master RM  WITH (NOLOCK)
      Inner join T0052_HRMS_Posted_Recruitment RP WITH (NOLOCK) on RM.Rec_Post_ID = RP.Rec_Post_ID    
      where Rm.Resume_Status =0 and RM.Cmp_id=@Cmp_ID   
      Order by RP.Job_Title  
        
  Select * from @dash  
    
     End  
       
    Else if @Resume_Status = 1  
      Begin   
      
      Insert into @dash (Resume_ID,Job_Title,App_Full_name,App_First_name,Total_Exp,Gender,Resume_Status)  
   Select RM.Resume_ID,RP.Job_Title,(RM.Emp_First_name + ' - ' + RM.Emp_Last_name) as Emp_first_name,Rm.Emp_First_name,RM.Total_Exp,RM.Gender,RM.Resume_Status   
    from T0055_Resume_master RM  WITH (NOLOCK) 
    Inner join T0052_HRMS_Posted_Recruitment RP WITH (NOLOCK) on RM.Rec_Post_ID = RP.Rec_Post_ID    
    where Rm.Resume_Status =1 and RM.Cmp_id=@Cmp_ID Order by RP.Job_Title  
        
      Select * from @dash  
       
     End  
    Else if @Resume_Status = 2  
      Begin   
      
     Insert into @dash (Resume_ID,Job_Title,App_Full_name,App_First_name,Total_Exp,Gender,Resume_Status)  
  Select RM.Resume_ID,RP.Job_Title,(RM.Emp_First_name + ' - ' + RM.Emp_Last_name) as Emp_first_name,Rm.Emp_First_name,RM.Total_Exp,RM.Gender,RM.Resume_Status   
   from T0055_Resume_master RM  WITH (NOLOCK) 
      Inner join T0052_HRMS_Posted_Recruitment RP WITH (NOLOCK) on RM.Rec_Post_ID = RP.Rec_Post_ID    
      where Rm.Resume_Status =2 and RM.Cmp_id=@Cmp_ID Order by RP.Job_Title  
        
  Select * from @dash  
       
      End  

Else if @Resume_Status = 3  
      Begin   
      
		Insert into @dash (Resume_ID,Job_Title,App_Full_name,App_First_name,Total_Exp,Gender,Resume_Status)  
     
		Select RM.Resume_ID,RP.Job_Title,(RM.Emp_First_name + ' - ' + RM.Emp_Last_name) as Emp_first_name,Rm.Emp_First_name,RM.Total_Exp,RM.Gender,RM.Resume_Status   
		from T0055_Resume_master RM WITH (NOLOCK) 
		Inner join T0052_HRMS_Posted_Recruitment RP WITH (NOLOCK) on RM.Rec_Post_ID = RP.Rec_Post_ID    
		where Rm.Resume_Status =3 and RM.Cmp_id=@Cmp_ID Order by RP.Job_Title  
        
		Select * from @dash  
       
      End  
       
Else if @Resume_Status =4
    Begin 
     Declare @Resume_Satus table
     (
       Approve numeric(18,0),
       Reject numeric(18,0),
       Hold  numeric(18,0),
       New  numeric(18,0)
     )
     
     declare @Reject as numeric
     declare @Hold as numeric
     Declare @new as numeric
     
     insert into @Resume_Satus(Approve,Reject,Hold,New)

     Select Count(Resume_ID),0,0,0 as Resume_ID from T0055_REsume_master WITH (NOLOCK)
      where Cmp_ID=@Cmp_ID  and Resume_Status =1

     Select @Reject =Count(Resume_ID) from T0055_REsume_master WITH (NOLOCK)
      where Cmp_ID=@Cmp_ID  and Resume_Status =3

 Select @Hold =Count(Resume_ID) from T0055_REsume_master WITH (NOLOCK)
      where Cmp_ID=@Cmp_ID  and Resume_Status =2

 Select @new =Count(Resume_ID) from T0055_REsume_master WITH (NOLOCK)
      where Cmp_ID=@Cmp_ID  and Resume_Status =0
      
      Update @Resume_Satus 
              set Reject =@Reject,Hold =@Hold,New=@new
    

   Select * from @Resume_Satus
      
   End  



RETURN  




