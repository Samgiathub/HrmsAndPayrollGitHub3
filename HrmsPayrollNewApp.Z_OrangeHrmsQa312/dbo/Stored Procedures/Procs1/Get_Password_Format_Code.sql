
---30/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE  [dbo].[Get_Password_Format_Code]
	@Emp_ID int,
	@Cmp_ID int
AS
BEGIN

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	declare @Password_Form_16 varchar(max)
	declare @Password_Salary_Slip varchar(max)
	declare @Emp_Code varchar(50)
	declare @PAN_Card varchar(50)
	declare @Date_Of_Join datetime
	declare @Date_Of_Birth datetime
	Declare @Employee_First_Name varchar(100)
	Declare @Employee_Last_Name varchar(100)
	Declare @Form_16_Name_Length int
	Declare @Salary_Slip_Name_Length int
	Declare @Format_Form_16 as varchar(max)
	Declare @Format_Salary_Slip as varchar(max)
	Declare @Example_Form_16 as varchar(max)
    Declare @Example_Name as varchar(max)
    Declare @Example_Salary_Slip as varchar(max)
    Declare @Example_Salary_Slip_Name as varchar(max)
    
    
    set @Example_Salary_Slip = ''
    set @Example_Salary_Slip_Name = ''
	set @Example_Name = ''
	set @Example_Form_16 = ''
	set @Password_Form_16 = ''
	set @Password_Salary_Slip = ''
	set @Emp_Code = ''
	set @PAN_Card = ''
	set @Date_Of_Birth = null
	set @Date_Of_Join = null
	set @Employee_First_Name = ''
	set @Employee_Last_Name = ''
	set @Form_16_Name_Length = 0
	set @Salary_Slip_Name_Length = 0
	set @Format_Form_16 = ''
	set @Format_Salary_Slip = ''
	
	select @Emp_Code = Alpha_emp_code,
		   @PAN_Card = Pan_No,
		   @Date_Of_Birth = Date_Of_Birth,
		   @Date_Of_Join =Date_Of_Join,
		   @Employee_First_Name = Emp_First_Name,
		   @Employee_Last_Name =Emp_Last_Name  
		   from V0080_EMP_MASTER_INCREMENT_GET where Emp_ID = @Emp_ID and Cmp_ID = @Cmp_ID
		
		 
	
	select @Password_Form_16 = replace(Format,' + ','') from V0250_Password_Format_Setting where cmp_ID = @Cmp_ID and Page_Name = 'Form-16'
	select @Password_Salary_Slip = replace(Format, ' + ','') from V0250_Password_Format_Setting where cmp_ID = @Cmp_ID and Page_Name = 'Salary Slip'

	
	if PATINDEX('%[0-9]%',@Password_Form_16) > 0
		select @Form_16_Name_Length =  SubString(@Password_Form_16,PATINDEX('%[0-9]%',@Password_Form_16),1)
	
	if @Password_Form_16 <> ''
		begin
				set @Format_Form_16 =  UPPER(@Password_Form_16)
				if @Form_16_Name_Length > 0
				begin
					set @Format_Form_16 = REPLACE(@Password_Form_16,@Form_16_Name_Length,'(First ' + CONVERT(varchar(10),@Form_16_Name_Length) + ' Characters)')
				end
				else
				begin
					set @Format_Form_16 = @Password_Form_16
				end
				
				set @Format_Form_16 = REPLACE(@Format_Form_16,'EFN','[Employee First Name]')
				set @Format_Form_16 = REPLACE(@Format_Form_16,'ELN','[Employee Last Name]')
				set @Format_Form_16 = REPLACE(@Format_Form_16,'EC','[Employee Code]')
				set @Format_Form_16 = REPLACE(@Format_Form_16,'PAN','[PAN Card]')
				set @Format_Form_16 = REPLACE(@Format_Form_16,'DOB','[Date of Birth]')
				set @Format_Form_16 = REPLACE(@Format_Form_16,'DOJ','[Date of Join]')
				set @Example_Form_16 = UPPER(Replace(@Format_Form_16,' + ',''))
				set @Format_Form_16 = 'Form-16 Password Hint : <b>' + UPPER(Replace(@Format_Form_16,' + ','')) + ' </b><br></br><br></br> Note :<br></br> 1) Date Format is ddMMyyyy<br></br> 2) All Characters Should be in Capital Letters'
				
		end
	else
		begin
			set @Example_Form_16 = ''
	  		set @Format_Form_16 = 'Form-16 Password Hint : <b> Your Login Password </b>'  
		end
	

	if @Password_Form_16 <> '' 
		begin
			if  @Form_16_Name_Length > 0
				select @Password_Form_16 = REPLACE(@Password_Form_16,@Form_16_Name_Length,'')
			
			
			if  @Form_16_Name_Length > 0 
				begin
					select @Password_Form_16 = REPLACE(@Password_Form_16,'EFN',Substring(isnull(@Employee_First_Name,''),1,@Form_16_Name_Length))
					select @Password_Form_16 = REPLACE(@Password_Form_16,'ELN',Substring(isnull(@Employee_Last_Name,''),1,@Form_16_Name_Length))
				end
			else
				begin
					select @Password_Form_16 = REPLACE(@Password_Form_16,'EFN',isnull(@Employee_First_Name,''))
					select @Password_Form_16 = REPLACE(@Password_Form_16,'ELN',isnull(@Employee_Last_Name,''))
				end
	
			select @Password_Form_16 = REPLACE(@Password_Form_16,'EC',isnull(@Emp_Code,''))
			select @Password_Form_16 = REPLACE(@Password_Form_16,'PAN',isnull(@PAN_Card,''))	
			
			if  @Date_Of_Birth is null
				begin
					select @Password_Form_16 = REPLACE(@Password_Form_16,'DOB', '')
				end	
			else
				begin
					select @Password_Form_16 = REPLACE(@Password_Form_16,'DOB', Replace(Convert(varchar(25),@Date_Of_Birth,103),'/',''))
				end
			if  @Date_Of_Join is null
				begin
					select @Password_Form_16 = REPLACE(@Password_Form_16,'DOJ','')
				end
			else
				begin
					select @Password_Form_16 = REPLACE(@Password_Form_16,'DOJ',Replace(Convert(varchar(25),@Date_Of_Join,103),'/',''))		
				end	
		end
	 
	
	if PATINDEX('%[0-9]%',@Password_Salary_Slip) > 0
		select @Salary_Slip_Name_Length =  SubString(@Password_Salary_Slip,PATINDEX('%[0-9]%',@Password_Salary_Slip),1)
		
	if @Password_Salary_Slip <> ''
		begin
				if @Salary_Slip_Name_Length > 0
				begin
					--set @Format_Salary_Slip = REPLACE(@Password_Salary_Slip,@Salary_Slip_Name_Length,'[Employee Name Length - ' + CONVERT(varchar(10),@Salary_Slip_Name_Length) + ']')
					set @Format_Salary_Slip = REPLACE(@Password_Salary_Slip,@Salary_Slip_Name_Length,'(First ' + CONVERT(varchar(10),@Salary_Slip_Name_Length) + ' Characters)')
				end 
				else
				begin
					set	@Format_Salary_Slip = @Password_Salary_Slip
				end
				set @Format_Salary_Slip = REPLACE(@Format_Salary_Slip,'EFN','[Employee First Name]')
				set @Format_Salary_Slip = REPLACE(@Format_Salary_Slip,'ELN','[Employee Last Name]')
				set @Format_Salary_Slip = REPLACE(@Format_Salary_Slip,'EC','[Employee Code]')
				set @Format_Salary_Slip = REPLACE(@Format_Salary_Slip,'PAN','[PAN Card]')
				set @Format_Salary_Slip = REPLACE(@Format_Salary_Slip,'DOB','[Date of Birth]')
				set @Format_Salary_Slip = REPLACE(@Format_Salary_Slip,'DOJ','[Date of Join]')
				set @Example_Salary_Slip = UPPER(Replace(@Format_Salary_Slip,' + ',''))
				
				set @Format_Salary_Slip = 'Salary Slip Password Hint :<b> ' + UPPER(@Format_Salary_Slip) + ' </b><br></br>Note :<br></br><br></br> 1) Date Format is ddMMyyyy<br></br> 2) All Characters Should be in Capital Letters. <br></br> 3) If PAN Card is not updated,then Date-of-Join will be your Password.'
		end
	else
		begin
			set @Format_Salary_Slip	= 'Salary Slip Password Hint :<b> [PANCARD][DATE OF JOIN] </b><br></br><br></br> Note : <br></br><br></br> 1) Date Format is ddMMyyyy<br></br> 2) All Characters Should be in Capital Letters. <br></br> 3) If PAN Card is not updated,then Date-of-Join will be your Password.'
		end
		
	if @Password_Salary_Slip <> ''
		begin
			if  @Salary_Slip_Name_Length > 0
						select @Password_Salary_Slip = REPLACE(@Password_Salary_Slip,@Salary_Slip_Name_Length,'')
						
				if  @Salary_Slip_Name_Length > 0 
					begin
						
						select @Password_Salary_Slip = REPLACE(@Password_Salary_Slip,'EFN',Substring(isnull(@Employee_First_Name,''),1,@Salary_Slip_Name_Length))
					
						select @Password_Salary_Slip = REPLACE(@Password_Salary_Slip,'ELN',Substring(isnull(@Employee_Last_Name,''),1,@Salary_Slip_Name_Length))
					end
				else
					begin
						select @Password_Salary_Slip = REPLACE(@Password_Salary_Slip,'EFN',isnull(@Employee_First_Name,''))
						select @Password_Salary_Slip = REPLACE(@Password_Salary_Slip,'ELN',isnull(@Employee_Last_Name,''))
				end	
				
		
				select @Password_Salary_Slip = REPLACE(@Password_Salary_Slip,'EC',isnull(@Emp_Code,''))
				select @Password_Salary_Slip = REPLACE(@Password_Salary_Slip,'PAN',isnull(@PAN_Card,''))		
				
			
				if @Date_Of_Birth is null 
					begin
						select @Password_Salary_Slip = REPLACE(@Password_Salary_Slip,'DOB', '')
					end	
				else
					begin
						select @Password_Salary_Slip = REPLACE(@Password_Salary_Slip,'DOB', Replace(Convert(varchar(25),@Date_Of_Birth,103),'/',''))
					end
				if @Date_Of_Join is null
					begin
						select @Password_Salary_Slip = REPLACE(@Password_Salary_Slip,'DOJ','')
					end
				else
					begin
						select @Password_Salary_Slip = REPLACE(@Password_Salary_Slip,'DOJ',Replace(Convert(varchar(25),@Date_Of_Join,103),'/',''))		
					end
		end
			
			 if CHARINDEX('[Employee First Name]',@Example_Form_16) > 0
				begin
				   set @Example_Name = 'Employee First Name = Prakash'
				end
			  if CHARINDEX('[Employee Last Name]',@Example_Form_16) > 0
				begin
					if @Example_Name <> '' 
					begin
						set @Example_Name = @Example_Name + '<br></br> Employee Last Name = Patel'
					end
					else
					begin
						set @Example_Name = 'Employee Last Name = Patel'
					end
				end
			 if CHARINDEX('[Employee Code]',@Example_Form_16) > 0
				begin
					if @Example_Name <> '' 
					begin
						set @Example_Name = @Example_Name + '<br></br> Employee Code = 5001'
					end
					else
					begin
						set @Example_Name = 'Employee Code = 5001'
					end
				end	
			  if CHARINDEX('[PAN Card]',@Example_Form_16) > 0
				begin
					if @Example_Name <> '' 
					begin
						set @Example_Name = @Example_Name + '<br></br> PAN Card = ABCD1234F'
					end
					else
					begin
						set @Example_Name = ' PAN Card = ABCD1234F'
					end
				end	
			 
			 if CHARINDEX('[Date of Birth]',@Example_Form_16) > 0
				begin
					if @Example_Name <> '' 
					begin
						set @Example_Name = @Example_Name + '<br></br> Date of Birth = 12/08/1985'
					end
					else
					begin
						set @Example_Name = 'Date of Birth = 12/08/1985'
					end
				end	
			if CHARINDEX('[Date of Join]',@Example_Form_16) > 0
				begin
					if @Example_Name <> '' 
					begin
						set @Example_Name = @Example_Name + '<br></br> Date of Join = 01/05/2013'
					end
					else
					begin
						set @Example_Name = 'Date of Join = 01/05/2013'
					end
				end		
				
			if @Example_Form_16 <> '' 
			begin
						
									
						set @Example_Form_16 = REPLACE(@Example_Form_16,'[Employee First Name]','Prakash')
						set @Example_Form_16 = REPLACE(@Example_Form_16,'[Employee Last Name]','Patel')
						if @Form_16_Name_Length > 0 
						begin
							set @Example_Form_16 = REPLACE(@Example_Form_16,'Prakash',Substring(isnull('Prakash',''),1,@Form_16_Name_Length))
							set @Example_Form_16 = REPLACE(@Example_Form_16,'Patel',Substring(isnull('Patel',''),1,@Form_16_Name_Length))
							set @Example_Form_16 = REPLACE(@Example_Form_16,'(First ' + CONVERT(varchar(10),@Form_16_Name_Length) + ' Characters)','')
						end 
						set @Example_Form_16 = REPLACE(@Example_Form_16,'[Employee Code]','5001')
						set @Example_Form_16 = REPLACE(@Example_Form_16,'[PAN Card]','ABCD1234F')
						set @Example_Form_16 = REPLACE(@Example_Form_16,'[Date of Birth]','12081985')
						set @Example_Form_16 = REPLACE(@Example_Form_16,'[Date of Join]','01052013')
						set @Example_Form_16 = '<b>For Example : </b><br></br>' + Upper(@Example_Name) + '<br></br><br></br> Your Password = <b> '+ UPPER(@Example_Form_16) + '</b>'
					
			end
			
			

					IF OBJECT_ID('DBO.TEMPDB..#Example') IS NOT NULL
							DROP TABLE #Example

						CREATE TABLE #Example
						(	
							Short_Name	Varchar(10),
							Full_Name	Varchar(30),
							[Description] Varchar(50),
						)

						Insert Into #Example
						Values('EFN','[Employee First Name]','Prakash')

						Insert Into #Example
						Values('ELN','[Employee Last Name]','Patel')

						Insert Into #Example
						Values('EC','[Employee Code]','5001')

						Insert Into #Example
						Values('PAN','[PAN Card]','ABCD1234F')

						Insert Into #Example
						Values('DOB','[Date of Birth]','12081985')

						Insert Into #Example
						Values('DOJ','[Date of Join]','01052013')


									
						Declare @Format_PaySlip as Varchar(50)
						Select  @Format_PaySlip = [format] FROM V0250_Password_Format_Setting 
						where  cmp_Id = @Cmp_ID and Page_Name = 'Salary Slip'
						

						SELECT  @Example_Salary_Slip_Name = @Example_Salary_Slip_Name + '<br></br>' + (E.Full_Name + '=' + E.[Description])
						FROM	#Example E Inner Join 
								(
									select	d.*
									from	dbo.split(@Format_PaySlip,'+') d 	
								)Q	On E.Short_Name = Q.Data
						order by q.id						
						

						--select data,id from dbo.split(@Format_PaySlip,'+')
						


			-- if CHARINDEX('[Employee First Name]',@Example_Salary_Slip) > 0
			--	begin
			--	   set @Example_Salary_Slip_Name = 'Employee First Name = Prakash'
			--	end
			--  if CHARINDEX('[Employee Last Name]',@Example_Salary_Slip) > 0
			--	begin
			--		if @Example_Salary_Slip_Name <> '' 
			--		begin
			--			set @Example_Salary_Slip_Name = @Example_Salary_Slip_Name + '<br></br> Employee Last Name = Patel'
			--		end
			--		else
			--		begin
			--			set @Example_Salary_Slip_Name = 'Employee Last Name = Patel'
			--		end
			--	end
			-- if CHARINDEX('[Employee Code]',@Example_Salary_Slip) > 0
			--	begin
			--		if @Example_Salary_Slip_Name <> '' 
			--		begin
			--			set @Example_Salary_Slip_Name = @Example_Salary_Slip_Name + '<br></br> Employee Code = 5001'
			--		end
			--		else
			--		begin
			--			set @Example_Salary_Slip_Name = 'Employee Code = 5001'
			--		end
			--	end	
			--  if CHARINDEX('[PAN Card]',@Example_Salary_Slip) > 0
			--	begin
			--		if @Example_Salary_Slip_Name <> '' 
			--		begin
			--			set @Example_Salary_Slip_Name = @Example_Salary_Slip_Name + '<br></br> PAN Card = ABCD1234F'
			--		end
			--		else
			--		begin
			--			set @Example_Salary_Slip_Name = ' PAN Card = ABCD1234F'
			--		end
			--	end	
			 
			-- if CHARINDEX('[Date of Birth]',@Example_Salary_Slip) > 0
			--	begin
			--		if @Example_Salary_Slip_Name <> '' 
			--		begin
			--			set @Example_Salary_Slip_Name = @Example_Salary_Slip_Name + '<br></br> Date of Birth = 12/08/1985'
			--		end
			--		else
			--		begin
			--			set @Example_Salary_Slip_Name = 'Date of Birth = 12/08/1985'
			--		end
			--	end	
			--if CHARINDEX('[Date of Join]',@Example_Salary_Slip) > 0
			--	begin
			--		if @Example_Salary_Slip_Name <> '' 
			--		begin
			--			set @Example_Salary_Slip_Name = @Example_Salary_Slip_Name + '<br></br> Date of Join = 01/05/2013'
			--		end
			--		else
			--		begin
			--			set @Example_Salary_Slip_Name = 'Date of Join = 01/05/2013'
			--		end
			--	end		
				
			if @Example_Salary_Slip <> '' 
			begin
												
						

						set @Example_Salary_Slip = REPLACE(@Example_Salary_Slip,'[Employee First Name]','Prakash')
						set @Example_Salary_Slip = REPLACE(@Example_Salary_Slip,'[Employee Last Name]','Patel')
						if @Salary_Slip_Name_Length > 0 
						begin
							set @Example_Salary_Slip = REPLACE(@Example_Salary_Slip,'Prakash',Substring(isnull('Prakash',''),1,@Salary_Slip_Name_Length))
							set @Example_Salary_Slip = REPLACE(@Example_Salary_Slip,'Patel',Substring(isnull('Patel',''),1,@Salary_Slip_Name_Length))
							set @Example_Salary_Slip = REPLACE(@Example_Salary_Slip,'(First ' + CONVERT(varchar(10),@Salary_Slip_Name_Length) + ' Characters)','')
						end 
						set @Example_Salary_Slip = REPLACE(@Example_Salary_Slip,'[Employee Code]','5001')
						set @Example_Salary_Slip = REPLACE(@Example_Salary_Slip,'[PAN Card]','ABCD1234F')
						set @Example_Salary_Slip = REPLACE(@Example_Salary_Slip,'[Date of Birth]','12081985')
						set @Example_Salary_Slip = REPLACE(@Example_Salary_Slip,'[Date of Join]','01052013')
						set @Example_Salary_Slip = '<b>For Example : </b><br></br>' +Upper(@Example_Salary_Slip_Name) + '<br></br><br></br> Your Password = <b>'+  Upper(@Example_Salary_Slip) + '</b>'
					
			end
	
	
								
		select Upper(@Password_Form_16) as Form16_Password,Upper(@Password_Salary_Slip) as Salary_Slip_Password,@Format_Form_16 as Format_Form_16,@Format_Salary_Slip as Format_Salary_Slip,@Example_Form_16 as Example_Form_16 ,@Example_Salary_Slip as Example_Salary_Slip  /*,@Password_Example as Password_Example*/
		
    
END


