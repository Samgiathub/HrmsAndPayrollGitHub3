CREATE PROCEDURE [dbo].[KPMS_SP0020_SelectTarget_SatusGrid]                                     
(                                    
 @Emp_ID int   
 ,@Cmp_ID int
)                                    
as                                         
 BEGIN                                    
  Declare @lResult4 varchar(max) =''                    
  --Declare @lResult varchar(max) =''                
          
 -- select @lResult = @lResult + apprr_Result from kpms_Approval_Result where emp_id = @Emp_ID          
          
 Select @lResult4 = @lResult4 +                     
 '<tr>            
 <td>' + GoalSheet_Name + '</td>                   
   <td>             
     <a href="javascript:;" onclick="ShowAddNew(' + CONVERT(VARCHAR,Goal_Allot_ID) + ')"><i class="fa fa-pencil-square-o fa-lg" aria-hidden="true"></i></a>               
  
 </td>                  
 <tr>'  from KPMS_T0020_Goal_Allotment_Master_Test as gat             
 where Emp_ID=@Emp_ID and Cmp_Id = @Cmp_ID                      
 

 Declare @lResult5 varchar(max) =''      
	 Select @lResult5 = @lResult5 + Status_Name from  kpms_Approval_Result  as kp inner join kpms_Approve_Status on Appr_Status_ID = apprr_Result where Emp_ID=@Emp_ID  and kp.cmp_id = @Cmp_ID     

   select @lResult4  as Result4  , @lResult5  as Result5                                    
END                   
                  
 --<td>                        
--- <a href="javascript:;" onclick="ShowAddNew(' + CONVERT(VARCHAR,Goal_Allot_ID) + ')"><i class="fa fa-pencil-square-o fa-lg" aria-hidden="true"></i></a>                           
 --<a href="javascript:;" onclick="EditData(' + CONVERT(VARCHAR,Goal_Allot_ID) + ')"><i class="fa fa-pencil-square-o fa-lg" aria-hidden="true"></i></a>                        
 --<a href="javascript:;" onclick="ChangeStatus(' + CONVERT(VARCHAR,Goal_Allot_ID) + ',2)"><i class="fa fa-trash fa-lg" aria-hidden="true"></i></a>                        
 --</td> 

 --<a href="javascript:;" onclick="ChangeStatus(' + CONVERT(VARCHAR,Goal_Allot_ID) + ',2)"><i class="fa fa-trash fa-lg" aria-hidden="true"></i></a>                        