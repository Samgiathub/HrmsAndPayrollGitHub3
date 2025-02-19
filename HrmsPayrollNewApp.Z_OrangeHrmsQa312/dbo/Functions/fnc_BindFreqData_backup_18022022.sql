create function [dbo].[fnc_BindFreqData_backup_18022022](@GSG_FrequecyId int,@Emp_ID int,@rowid int)                          
returns varchar(max)                          
as                          
begin                       
  DECLARE @MONTH TABLE        
   (        
     Srno int,        
     MonthNm int,        
     MonthName Varchar(50)        
   )        
        
   INSERT INTO @MONTH        
   VALUES         
   (1,4,'APR'),        
   (2,5,'MAY'),        
   (3,6,'JUN'),        
   (4,7,'JUL'),        
   (5,8,'AUG'),         
   (6,9,'SEP'),         
   (7,10,'OCT'),         
   (8,11,'NOV'),         
   (9,12,'DEC'),         
   (10,1,'JAN'),         
   (11,2,'FEB'),         
   (12,3,'MAR')         
   DECLARE @count INT;        
   declare @lresult varchar(max)=''        
   declare @r2 varchar(max)=''        
   declare @lRF varchar(50)=''        
   SET @count = 1;        
   declare @total varchar(max)=''        
           
  if(@GSG_FrequecyId = 1)                 
  Begin         
  select @total = @total + Achievement from kpms_FrqWise_Target_Achievement where emp_id= @Emp_ID and freq_id = 1;        
   WHILE @count<= 12        
   BEGIN        
   declare @m as int = 0        
        
   declare @mnm as varchar(50) = ''        
   select @m = MonthNm , @mnm = MonthName from @MONTH where Srno = @count        
           
   if((MONTH(GETDATE())=@m)) --or (MONTH(GETDATE())-1)=@m)        
   begin        
    if((convert(varchar, getdate(), 23)) <= dateadd(day,10,EOMONTH(DATEADD(day, -1, getdate()))))        
     begin        
       select @lRF = 'enabled'        
     end        
   end        
   else        
   begin        
     begin        
       select @lRF = 'disabled'               
     end        
   end         
        
         
  --select @r2 = @r2 + '<li><div class="input-group mb-3"><div class="input-group-prepend"><div class="input-group-text"><input type="checkbox" aria-label="Checkbox for following text input" id="m' + cast(@m as varchar(2)) + '"><i>&nbsp; '+@mnm+'</i> </div></div><input type="text" class="form-control" aria-label="Text input with checkbox" placeholder="Achievement" value='+cast(Achievement as varchar(50))+' id="mm'+ cast(@m as varchar(2))+'" '+@lRF+'='+@lRF+'></div></li>' from kpms_FrqWise_Target_Achievement where emp_id = @Emp_ID and freq_id = 1         
  select @r2 = @r2 + '<li><div class="input-group mb-3"><div class="input-group-prepend"><div class="input-group-text"><input type="checkbox" aria-label="Checkbox for following text input" id="m' + cast(@m as varchar(2)) + '"><i>&nbsp; '+@mnm+'</i> </div></div><input type="text" class="form-control" aria-label="Text input with checkbox" placeholder="Achievement" id="mm'+ cast(@m as varchar(2))+'" '+@lRF+'='+@lRF+'></div></li>'        
   SET @count = @count + 1;        
   END;        
    select @lresult = '<div class="button-group"><button type="button" class="btn btn-default btn-lg dropdown-toggle" data-toggle="dropdown"><span class="glyphicon glyphicon-cog"></span> <span class="caret" id="spanid">Monthy - Achievement</span></button> <ul class="dropdown-menu">'+@r2+'<li> <div class="input-group mb-3"><div class="input-group-prepend"><div class="input-group-text"><i>&nbsp; <b>Total: </b></i> </div></div><input type="text" class="form-control" aria-label="Text input with checkbox" placeholder="Achievement" id="AchiveTargetid"></div></li></ul></div>'        
  -- select @lresult = '<div class="button-group"><button type="button" class="btn btn-default btn-lg dropdown-toggle" data-toggle="dropdown"><span class="glyphicon glyphicon-cog"></span> <span class="caret">Monthy - Achievement</span></button> <ul class="dropdown-menu">'+@r2+'<li<div class="input-group mb-3"><div class="input-group-prepend"><div class="input-group-text"><i>&nbsp; <b>Total: </b></i> </div></div><input type="text" class="form-control" aria-label="Text input with checkbox" placeholder="Achievement" value='+@total+' id="AchiveTargetid"></div></li></ul></div>'        
  END        
  ELSE IF(@GSG_FrequecyId = 2)        
  BEGIN        
    select @total = @total + Achievement from kpms_FrqWise_Target_Achievement where emp_id= @Emp_ID and freq_id = 2;        
   WHILE @count<= 12        
   BEGIN        
   declare @m1 as int = 0        
   declare @mnm1 as varchar(50) = ''        
   select @m1 = MonthNm  , @mnm1 = MonthName from @MONTH where Srno = @count        
   if((MONTH(GETDATE())=@m1)) --or (MONTH(GETDATE())-1)=@m)        
   begin        
    if((convert(varchar, getdate(), 23)) <= dateadd(day,10,EOMONTH(DATEADD(day, -1, getdate()))))        
     begin        
       select @lRF = 'enabled'        
     end        
   end        
   else         
   begin        
     begin        
       select @lRF = 'disabled'               
     end        
   end        
        
           
   SET @count = @count + 1;        
   END;        
        
     SELECT @lResult =                         
      '                        
     <div class="button-group">                      
      <button type="button" class="btn btn-default btn-lg dropdown-toggle" data-toggle="dropdown"><span class="glyphicon glyphicon-cog"></span> <span class="caret" id="spanid">Quaterly - Achievement</span></button>                      
      <ul class="dropdown-menu">                      
        <li>                         
        <div class="input-group mb-3">                      
         <div class="quater-input-group-prepend">                      
        <div class="input-group-text">                      
          <input type="checkbox" aria-label="Checkbox for following text input" id="q1">                      
          <i>&nbsp; Apr,</i> <i>&nbsp; May,</i> <i>&nbsp; Jun</i> </div>                      
         </div>                      
         <input type="text" class="form-control" aria-label="Text input with checkbox" placeholder="Achievement" id="mq1" @lRF="@lRF" disabled>                      
       </div>                      
       <div class="input-group mb-3">                      
         <div class="quater-input-group-prepend">                      
        <div class="input-group-text">                      
          <input type="checkbox" aria-label="Checkbox for following text input" id="q2">                      
          <i>&nbsp; Jul</i> <i>&nbsp; Aug,</i> <i>&nbsp; Sep</i> </div>                      
         </div>                      
         <input type="text" class="form-control" aria-label="Text input with checkbox" placeholder="Achievement" id="mq2" @lRF="@lRF" disabled>                      
       </div>                      
       <div class="input-group mb-3">                      
         <div class="quater-input-group-prepend">                      
        <div class="input-group-text">                      
          <input type="checkbox" aria-label="Checkbox for following text input" id="q3">                       
          <i>&nbsp; Oct</i> <i>&nbsp; Nov,</i> <i>&nbsp; Dec</i> </div>                      
         </div>                      
         <input type="text" class="form-control" aria-label="Text input with checkbox" placeholder="Achievement" id="mq3" @lRF="@lRF" disabled>                      
       </div>                      
       <div class="input-group mb-3">                      
         <div class="quater-input-group-prepend">                      
        <div class="input-group-text">                      
          <input type="checkbox" aria-label="Checkbox for following text input" id="q4">                      
          <i>&nbsp; Jan</i> <i>&nbsp; Feb,</i> <i>&nbsp; Mar</i> </div>                      
         </div>                      
         <input type="text" class="form-control" aria-label="Text input with checkbox" placeholder="Achievement" id="mq4" @lRF="@lRF">                      
       </div>                      
        </li>                      
        <li>                      
        <div class="input-group mb-3">                      
       <div class="input-group-prepend">                      
         <div class="input-group-text">             
        <i>&nbsp; <b>Total: </b></i> </div>                      
       </div>                      
       <input type="text" class="form-control" aria-label="Text input with checkbox" placeholder="Achievement" id="AchiveTargetid" value='+@total+'>                      
        </div>                  
      </li>                     
      </ul>                      
       </div>                
      '        
  END        
  ELSE        
  BEGIN        
    SELECT @lResult =                         
      '                        
     <div class="button-group">                      
      <button type="button" class="btn btn-default btn-lg dropdown-toggle" data-toggle="dropdown"><span class="glyphicon glyphicon-cog"></span> <span class="caret" id="spanid">Yearly - Achievement</span></button>                      
      <ul class="dropdown-menu">                      
        <li>                      
       <div class="input-group mb-3">                      
         <div class="input-group-prepend">                      
        <div class="Yearly-input-group-text">                      
          <input type="checkbox" aria-label="Checkbox for following text input" id="my12">                      
          <i>&nbsp; Apr-Mar</i> </div>                      
         </div>                      
         <input type="text" class="form-control" aria-label="Text input with checkbox" placeholder="Achievement" id="mmy12" @lRF="@lRF">                      
       </div>                      
        </li>                     
       <li>                      
        <div class="input-group mb-3">                      
       <div class="input-group-prepend">                      
         <div class="input-group-text">                      
        <i>&nbsp; <b>Total: </b></i> </div>                      
       </div>                      
       <input type="text" class="form-control" aria-label="Text input with checkbox" placeholder="Achievement" id="AchiveTargetid">                      
        </div>                      
      </li>                     
      </ul>                      
       </div>                
      '         
  END        
   return @lresult         
END