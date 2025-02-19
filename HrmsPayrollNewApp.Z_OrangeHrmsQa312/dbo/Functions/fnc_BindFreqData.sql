CREATE function [dbo].[fnc_BindFreqData](@GSG_FrequecyId int,@Emp_ID int,@levelassignID int) 
returns varchar(max)                            
as                            
begin                     
  declare @achi varchar(10)=''
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
    --if((MONTH(GETDATE())= (@m+1))) 
			 --begin          
			 -- if((convert(varchar, getdate(), 23)) <= DATEADD(dd, -DAY(GETDATE())+10, GETDATE()))          
			 -- begin          
			 --    select @lRF = 'enabled'          
			 --  end          
			 --end          
			 --else				
			 --begin          
			 --  begin          
			 --    select @lRF = 'disabled'                 
			 --  end        
   end           
          select @achi = Achievement from KPMS_T0110_TargetAchivement where Freq_id = 1 and levelAssignid = @levelassignID and Month_Num = @m and emp_id =@Emp_ID and Month = @mnm
			select @r2 = @r2 + '<li><div class="input-group mb-3"><div class="input-group-prepend"><div class="input-group-text"><input type="checkbox" aria-label="Checkbox for following text input" id="m' + cast(@m as varchar(2)) + '"><i>&nbsp; '+@mnm+'</i> </div>
			</div><input type="text" class="'+@mnm+'" aria-label="Text input with checkbox" value="'+@achi+'" placeholder="Achievement"  id="' + cast(@m as varchar(2)) + '" '+@lRF+'='+@lRF+'></div></li>'          
			SET @count = @count + 1;          
			END;          
			 select @lresult = '<div class="button-group"><button type="button" class="btn btn-default btn-lg dropdown-toggle" data-toggle="dropdown"><span class="glyphicon glyphicon-cog"></span> <span class="caret" id="spanid">Monthy - Achievement</span></button>
			 <ul class="dropdown-menu">'+@r2+'</ul></div>'        
  END  
	  
	  ELSE IF(@GSG_FrequecyId = 2)          
	  BEGIN          
		DECLARE @YEAR VARCHAR(30)
		SELECT @YEAR = YEAR(GETDATE())

		DECLARE @MONTH2 TABLE
				(
				  Srno int,
				  MonthNm varchar(500),
				  MonthName Varchar(50),
				  IsEnabled Int
				  ,Q_Date varchar(30)
				)

				INSERT INTO @MONTH2
				VALUES 
				(1,',4,5,6,','APR,MAY,JUN',0,(@year +'-07-01')),
				(2,',7,8,9,','JUL,AUG,SEP',0,(@year +'-10-01')),
				(3,',10,11,12,','OCT,NOV,DEC',0,(@year +'-01-01')),
				(4,',1,2,3,','JAN,FEB,MAR',0,(@year +'-04-01'))

		DECLARE @count2 varchar(500) = 1;
		         
		WHILE @count2<= 4       
		   BEGIN        
		   DECLARE @mm varchar(500)=''
		   DECLARE @mnmm as varchar(500) = ''        
		   DECLARE @sr int
		   DECLARE @iscase int
		   DECLARE @iscaseval varchar(20)=''
		   DECLARE @Qdate varchar(20)='' 
		   DECLARE @q_date_10 varchar(30) = ''
		   
				select @Qdate = Q_Date from @MONTH2 WHERE SRNO = @COUNT2
				select @q_date_10 = DATEADD(dd, -DAY(@Qdate)+10,@Qdate) 
		
				UPDATE @MONTH2 set ISENABLED = case when (GETDATE()>=@Qdate and GETDATE()<=@q_date_10)then 1 else 0 end WHERE SRNO = @COUNT2
				select @iscase = IsEnabled from @MONTH2 where Srno = @count2
		
		  if(CONVERT(VARCHAR,@iscase) = 0)
				begin
					 set @iscaseval = 'disabled'
				end
				else
				begin
					set @iscaseval = 'enabled'
				end

			select @mm = MonthNm , @mnmm = MonthName, @sr=Srno from @MONTH2 where Srno=@count2		
			select @achi =@achi + Achievement from KPMS_T0110_TargetAchivement where Freq_id = 2 and levelAssignid = @levelassignID and emp_id =@Emp_ID and Month = @mnmm
			
			select @r2 = @r2 + '
			 <li>
			  <div class="input-group mb-3">
			    <div class="quater-input-group-prepend">
			      <div class="input-group-text">
			        <input type="checkbox" aria-label="Checkbox for following text input" id="q'+cast(@sr as varchar(10))+'">
			       <i>&nbsp; '+ @mnmm +'</i> </div>      
			    </div>
			    	<input type="text"  class="'+@mnmm+'" aria-label="Text input with checkbox" value="'+@achi+'" placeholder="Achievement" id="' + cast(@mm as varchar(50)) + '" '+@iscaseval+'='+@iscaseval+'>  
				  </div>
				</li>'

		   SET @count2 = @count2 + 1; 

	 END
	 SELECT @lResult =                           
		  '<div class="button-group">
			  <button type="button" class="btn btn-default btn-lg dropdown-toggle" data-toggle="dropdown"> <span class="glyphicon glyphicon-cog"></span> <span class="caret" id="spanid" enabled="enabled">Quaterly - Achievement</span></button>
			  <ul class="dropdown-menu">
					'+@r2+'
			  </ul>
			</div>' 
	 END       
	 ELSE      
	 BEGIN   

		  select @achi =@achi + Achievement from KPMS_T0110_TargetAchivement where Freq_id = 3 and levelAssignid = @GSG_FrequecyId and emp_id =@Emp_ID

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
		        <input type="text"  class="Apr-Mar" aria-label="Text input with checkbox"  placeholder="Achievement" value="'+@achi+'" id="mm" disabled="disabled">                        
		      </div>                        
		       </li>  
		     </ul>                        
		      </div>                  
		     '           
		 END          
   return @lresult           
END
