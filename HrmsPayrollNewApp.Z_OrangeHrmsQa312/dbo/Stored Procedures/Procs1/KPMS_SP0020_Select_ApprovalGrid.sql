CREATE PROCEDURE [dbo].[KPMS_SP0020_Select_ApprovalGrid]     --KPMS_SP0020_Select_ApprovalTargetGrid          
(              
 @Emp_ID int          
)              
as                   
 BEGIN              
  Declare @lResult4 varchar(max) =''  
 Select @lResult4 = @lResult4+ '<tr><td>' + GoalSheet_Name + '<td></td><td>  
 <a href="javascript:;" onclick="EditData(' + CONVERT(VARCHAR,Goal_Allot_ID) + ')"><i class="fa fa-pencil-square-o fa-lg" aria-hidden="true"></i></a>  
 <a href="javascript:;" onclick="ChangeStatus(' + CONVERT(VARCHAR,Goal_Allot_ID) + ',2)"><i class="fa fa-trash fa-lg" aria-hidden="true"></i></a>  
 </td><tr><td>'  from KPMS_T0020_Goal_Allotment_Master_Test where Emp_ID=@Emp_ID  
   select @lResult4  as Result4    
     
END              
         