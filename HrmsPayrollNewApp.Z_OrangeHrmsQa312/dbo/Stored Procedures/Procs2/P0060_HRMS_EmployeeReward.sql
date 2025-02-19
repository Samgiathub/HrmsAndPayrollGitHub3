
  
---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---  
CREATE PROCEDURE [dbo].[P0060_HRMS_EmployeeReward]  
    @EmpReward_Id    numeric(18,0) output  
      ,@Cmp_Id      numeric(18,0)  
      ,@From_Date     datetime  
      ,@To_Date      datetime  
      ,@Employee_Id     varchar(500)  
      ,@Type      int  
      ,@RewardValues_Id    varchar(500)  
      ,@EmpReward_Rating   int  
      ,@Awards_Id     numeric(18,0)  
      ,@tran_type     varchar(1)   
   ,@User_Id      numeric(18,0) = 0  
   ,@IP_Address     varchar(30)= ''   
   ,@comments     nvarchar(500)=''  
     ,@Reward_Attachment   varchar(200)='' ---added on 22 dec 2015 sneha  
AS  
  
SET NOCOUNT ON   
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
SET ARITHABORT ON  
   set @comments = dbo.fnc_ReverseHTMLTags(@comments)  --ronak
BEGIN  
 If Upper(@tran_type) ='I'  
  Begin  
   select @EmpReward_Id = isnull(max(EmpReward_Id),0) + 1 from T0060_HRMS_EmployeeReward WITH (NOLOCK)  
   insert into T0060_HRMS_EmployeeReward  
   (  
       EmpReward_Id  
      ,Cmp_Id  
      ,From_Date  
      ,To_Date  
      ,Employee_Id  
      ,Type  
      ,RewardValues_Id  
      ,EmpReward_Rating  
      ,Awards_Id  
      ,comments  
      ,Reward_Attachment---added on 22 dec 2015 sneha  
   )  
   Values  
   (  
       @EmpReward_Id  
      ,@Cmp_Id  
      ,@From_Date  
      ,@To_Date  
      ,@Employee_Id  
      ,@Type  
      ,@RewardValues_Id  
      ,@EmpReward_Rating  
      ,@Awards_Id  
      ,@comments  
       ,@Reward_Attachment---added on 22 dec  2015 sneha  
   )  
  End  
 Else If Upper(@tran_type) ='U'  
  Begin  
   Update T0060_HRMS_EmployeeReward  
   set  From_Date  = @From_Date  
    ,To_Date  = @To_Date  
    ,Employee_Id = @Employee_Id  
    ,[Type]   = @type  
    ,RewardValues_Id = @RewardValues_Id  
    ,EmpReward_Rating = @EmpReward_Rating  
    ,Awards_Id  = @Awards_Id  
    ,comments=@comments  
    ,Reward_Attachment=@Reward_Attachment ---added on 22 dec  2015 sneha  
    where EmpReward_Id = @EmpReward_Id  
  End  
 Else If Upper(@tran_type) ='D'  
  Begin  
   Delete from T0060_HRMS_EmployeeReward where EmpReward_Id = @EmpReward_Id  
  End  
END  