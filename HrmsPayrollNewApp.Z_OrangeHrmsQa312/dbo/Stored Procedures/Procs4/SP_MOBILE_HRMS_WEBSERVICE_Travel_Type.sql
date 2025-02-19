--exec SP_MOBILE_HRMS_WEBSERVICE_Travel_Type 121,'D',''  
CREATE PROCEDURE [dbo].[SP_MOBILE_HRMS_WEBSERVICE_Travel_Type]
  @Cmp_ID INT  
    ,@Type VARCHAR(10)  
AS                      
BEGIN    
 IF(@Type = 'S')  
   BEGIN  
    Select Setting_Value from T0040_SETTING where Setting_Name = 'Enable Travel Type in Travel Module / Travel Expense' and Cmp_ID = @Cmp_ID  
   END  
 else IF(@Type = 'D')  
 BEGIN  
   if ((Select Setting_Value from T0040_SETTING where Setting_Name = 'Enable Travel Type in Travel Module / Travel Expense' and Cmp_ID = @Cmp_ID) = 1)  
   BEGIN  
    select Travel_Type_Id,Travel_Type_Name,DefualtState,SM.State_Name from T0040_Travel_Type TT  
    inner join T0020_STATE_MASTER  SM on TT.DefualtState = SM.State_ID where tt.DefualtState = sm.State_ID and tt.Cmp_Id = @Cmp_ID  
    order by Travel_Type_Sorting   
   END  
 END  
   
END
