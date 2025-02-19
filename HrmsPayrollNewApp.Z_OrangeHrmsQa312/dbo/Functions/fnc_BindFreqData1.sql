CREATE function [dbo].[fnc_BindFreqData1](@GSG_FrequecyId int)                  
returns varchar(max)                  
as                  
begin                  
	 if(@GSG_FrequecyId = 1)         
	 Begin 
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
    
			WHILE @count<= 12
			BEGIN
			declare @m as int = 0
			declare @mnm as varchar(50) = ''
			select @m = MonthNm  , @mnm = MonthName from @MONTH where Srno = @count
			if(MONTH(GETDATE())=@count)
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

			select @r2 = @r2 + '<li><div class="input-group mb-3"><div class="input-group-prepend"><div class="input-group-text"><input type="checkbox" aria-label="Checkbox for following text input" id="m' + cast(@m as varchar(2)) + '"><i>&nbsp; '+@mnm+'</i> </div></div><input type="text" class="form-control" aria-label="Text input with checkbox" placeholder="Achievement" id="mm'+ cast(@m as varchar(2))+'" '+@lRF+'='+@lRF+'></div></li>'
			
			SET @count = @count + 1;
			END;

			select @lresult = '<div class="button-group"><button type="button" class="btn btn-default btn-lg dropdown-toggle" data-toggle="dropdown"><span class="glyphicon glyphicon-cog"></span> <span class="caret">Monthy - Achievement</span></button> <ul class="dropdown-menu">'+@r2+'</ul></div>'

		END
		ELSE IF(@GSG_FrequecyId = 2)
		BEGIN
				 SELECT @lResult =                 
					 '                
					<div class="button-group">              
						<button type="button" class="btn btn-default btn-lg dropdown-toggle" data-toggle="dropdown"><span class="glyphicon glyphicon-cog"></span> <span class="caret">Quaterly - Achievement</span></button>              
						<ul class="dropdown-menu">              
						  <li>                 
					   <div class="input-group mb-3">              
							  <div class="quater-input-group-prepend">              
								<div class="input-group-text">              
								  <input type="checkbox" aria-label="Checkbox for following text input" id="q1">              
								  <i>&nbsp; Apr,</i> <i>&nbsp; May,</i> <i>&nbsp; Jun</i> </div>              
							  </div>              
							  <input type="text" class="form-control" aria-label="Text input with checkbox" placeholder="Achievement" id="mq1" @lRF="@lRF">              
							</div>              
							<div class="input-group mb-3">              
							  <div class="quater-input-group-prepend">              
								<div class="input-group-text">              
								  <input type="checkbox" aria-label="Checkbox for following text input" id="q2">              
								  <i>&nbsp; Jul</i> <i>&nbsp; Aug,</i> <i>&nbsp; Sep</i> </div>              
							  </div>              
							  <input type="text" class="form-control" aria-label="Text input with checkbox" placeholder="Achievement" id="mq2" @lRF="@lRF">              
							</div>              
							<div class="input-group mb-3">              
							  <div class="quater-input-group-prepend">              
								<div class="input-group-text">              
								  <input type="checkbox" aria-label="Checkbox for following text input" id="q3">               
								  <i>&nbsp; Oct</i> <i>&nbsp; Nov,</i> <i>&nbsp; Dec</i> </div>              
							  </div>              
							  <input type="text" class="form-control" aria-label="Text input with checkbox" placeholder="Achievement" id="mq3" @lRF="@lRF">              
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
							<input type="text" class="form-control" aria-label="Text input with checkbox" placeholder="Achievement" id="AchiveTargetid">              
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
						<button type="button" class="btn btn-default btn-lg dropdown-toggle" data-toggle="dropdown"><span class="glyphicon glyphicon-cog"></span> <span class="caret">Yearly - Achievement</span></button>              
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