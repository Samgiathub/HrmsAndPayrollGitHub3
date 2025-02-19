

---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_CheckLogin_Common_Ronakb090224]                   
   @Username				varchar(50) output          
  ,@Password				varchar(50) output          
  ,@IPAdd					varchar(20)          
  ,@Cmp_Id					numeric(18,0) output          
  ,@dateformate				numeric(18,0) output          
  ,@Emp_ID					numeric = null output          
  ,@Branch_ID				numeric = null output          
  ,@Login_Rights_ID			numeric = null output          
  ,@Cmp_Name				varchar(100) output          
  ,@Image_name				varchar(200) output          
  ,@Branch_Name				varchar(100) output          
  ,@tdate					datetime output          
  ,@ydate					datetime output          
  ,@Predate					datetime output          
  ,@Get_Login_ID			numeric(18,2) output 
  ,@Row_ID					numeric(18,2) output  
  ,@Login_type				numeric(1,0)  output   
  ,@m_status				numeric(18,0)=0 output  
  ,@From_Date				DateTime = null output			-- Nikunj 09-05-2011 For Dropdown Year bind in the system       
  ,@Login_In_out			Int = 0  Output
  ,@Login_In_out_Popup		Int = 0  Output					-- Added by Mitesh on 30/08/2011
  ,@Privilege_Id			Int = 0  Output					-- Added by Mitesh on 03/10/2011
  ,@Privilege_Type			Int = 0  Output					-- Added by Mitesh on 03/10/2011
  ,@is_GroupOfCompany		Int = 0 Output					-- Added by Mitesh on 10/10/2011
  ,@pBranch_id				Int = 0 Output					-- Added by Mitesh on 11/10/2011
  ,@pBranch_id_multi		varchar(Max) = 0 Output			-- Added by Mitesh on 15/03/2012
  ,@Emp_Search_Type			int = 0 output    
  ,@Dept_Id					numeric(18,0) =0 output			-- Add By Paras on 27-09-2012 
  ,@PVertical_ID_Multi		Varchar(Max) = 0 Output			-- Add By Gadriwala 14092013
  ,@PSubVertical_id_multi	Varchar(Max) = 0 Output			-- Add By Gadriwala 14092013
  ,@Timesheet_status		numeric(18,0)=0 output			-- Added by Prakash Patel 13012015 
  ,@pDepartment_Id_Multi	VARCHAR(MAX) = '0' Output		-- Added By Nimesh 27-Aug-2015
  ,@Module_Enable	VARCHAR(MAX) = '' Output		-- Added By Mukti 07012016
  ,@Email_Setting	VARCHAR(MAX) = '' Output		-- Added By Rohit on 18042016
  ,@MacAddress VARCHAR(100) = '' --Added by nilesh patel on 11/01/2017
  ,@InterNetIP Varchar(100) = '' --Added by nilesh patel on 11/06/2017
 AS        
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

		declare @userid as numeric(9)          
		declare @uname as varchar(30)          
		declare @Login_status as numeric(1,0)
		Declare @l_type as numeric(1,0)
		Declare @sql as varchar(5000)
		Declare @IO_Tran_ID As Numeric     
		Declare @In_Time As DateTime
		Declare @Out_Time As DateTime
		declare @is_active as tinyint	
		Declare @To_Date as DateTime
		declare @login_id_history as numeric
		declare @Emp_id_history as numeric
		declare @cmp_id_History as numeric
		declare @Username_History as varchar(100)
		declare @password_History as varchar(100)
		declare @Wrong_cnt as numeric
	
		SELECT @To_Date = dbo.Decrypt(LDate) from emp_lcount 
	
	
	
	set @pBranch_id_multi = 0
	set @PVertical_id_multi = 0  -- Added By Gadriwala 14092013
	set @PSubVertical_id_multi = 0 -- Added By Gadriwala 14092013
	set @is_active = 0
	set @pDepartment_Id_Multi = '0'	--Added by Nimesh 27-Aug-2015
	
	--Added By Mukti(start)04012016 
	if @Module_Enable=''
		set @Module_Enable=NULL
	declare @Module_Status as varchar(max)
	--Added By Mukti(end)04012016	
		
	--Code added By Ramiz 18/12/2018 for Restricting employees to login in Testing Companies and OTL Company
	DECLARE @Domain_Name as Varchar(100)
	DECLARE @Allow_MasterPassword_Login as BIT
	
	SET @Allow_MasterPassword_Login = 1
	SET @Domain_Name = SUBSTRING(@Username , CHARINDEX('@',@Username) , LEN(@Username))
	
	

	IF @Domain_Name in ('@leaveautomation1' , '@employeeautomation1' , '@AttendanceAutomation1' , '@salaryautomation1' , '@OTL')
		BEGIN
			SET @Allow_MasterPassword_Login = 0	--Master Password Disabled
		END
	--Code Ends By Ramiz on 18/12/2018
	
if @To_Date > getdate()
Begin   
	 if @Emp_ID = 0           
		 set @Emp_ID = null  
		 
		 CREATE table #check_Login
		 (
		 username varchar(100),
		 Wrong_cnt numeric
		 )
		 
		insert into #check_Login(username,Wrong_Cnt)
		exec P0100_login_check @Username
		


		select @Wrong_cnt = isnull(Wrong_cnt,0) from #check_Login
		

		

		IF EXISTS(SELECT Login_Id from T0011_Login WITH (NOLOCK) where (Login_Name=@Username OR login_alias = @Username ) and Login_password=@password and Isnull(Emp_ID,0) = Isnull(@Emp_ID,Isnull(Emp_ID,0)) )          
			BEGIN        
				SET @USERNAME_HISTORY = @Username
				SET @PASSWORD_HISTORY = @password
			

				SELECT @l_type = isnull(Is_Default,2),@is_active = Is_Active,@Emp_Search_Type=Emp_Search_Type  
				FROM T0011_Login WITH (NOLOCK)
				WHERE login_id=(select  top 1 Login_Id from T0011_Login WITH (NOLOCK) where (Login_Name=@Username OR login_alias=@Username) and Login_password=@password order by Login_Id desc) --Change by ronakk 06072023
	 
			if not @is_active = 1
				BEGIN
					 set @Username=0          
					 set @password=0          
					 set @cmp_Id=0          
					 set @dateformate=2          
					 set @Emp_ID =  0          
					 set @Branch_ID =  0          
					 set @tdate = getdate()           
					 set @ydate = getdate()-1          
					 set @Predate = getdate()-2    
					 set @Get_Login_ID = -1
					 set @Login_type = -1
					 set @l_type = -1
					set @Login_Rights_ID = 0
					set @Emp_Search_Type=0
					return -1
				END 
			
			

			if @l_type = 1 Or @l_type = 3
				set @l_type =0
			
			Set @Login_type = @l_type

			if @l_type = @Login_type
				begin 



			
						  
					select @Get_Login_ID=Login_ID,@Login_Rights_ID=Login_Rights_ID,@Username=Login_Name,@Cmp_id=T0011_Login.cmp_Id ,@Emp_ID= Emp_ID,@Branch_Id = Branch_Id, @tdate = convert(datetime, convert(varchar(24), GETDATE(), 120)),@ydate = convert(datetime, convert(varchar(24), GETDATE(), 120))-1,@Predate = convert(datetime, convert(varchar(24), GETDATE(), 120))-2,@Emp_Search_Type=Emp_Search_Type 
					from T0011_Login WITH (NOLOCK) inner JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) -- Added by Nilesh For Active & Inactive Company in Company Master on 22092015
					ON CM.Cmp_Id = T0011_Login.Cmp_ID
					where CM.IS_Active = 1 And (Login_Name=@Username OR login_alias=@Username) and Login_password=@password and Isnull(Emp_ID,0) = Isnull(@Emp_ID,Isnull(Emp_ID,0))                                
					And ISNULL( Effective_Date,'' )<= (Select MAX(Effective_Date) From T0011_LOGIN WITH (NOLOCK) Where (Login_Name=@Username OR login_alias = @Username ) and Login_password=@Password and Effective_Date<=GETDATE()) -- company transger added by mitesh on 24012014
					
					select @dateformate=date_format,@Cmp_Name = Cmp_Name ,@Image_name = Image_name,@From_Date=From_date,@is_GroupOfCompany = ISNULL(is_GroupOFCmp,0) from T0010_Company_master WITH (NOLOCK) where Cmp_ID= @Cmp_id          
					
					SELECT	Top 1 @Branch_ID=Branch_ID
					FROM	T0095_Increment I WITH (NOLOCK)
					WHERE	Emp_ID=@Emp_ID
					Order BY Increment_Effective_Date Desc, Increment_ID Desc
		
					select @Branch_Name = Branch_Name from T0030_Branch_master WITH (NOLOCK) where Branch_Id= @Branch_Id 
					
					
					SELECT	@Privilege_Type=PM.PRIVILEGE_TYPE,@Privilege_Id=PM.PRIVILEGE_ID,@pBranch_id=isnull(branch_id,0),
							@pBranch_id_multi = ISNULL(Branch_Id_Multi,0),@PVertical_id_multi = ISNULL(Vertical_ID_Multi,0),
							@PSubVertical_id_multi = ISNULL(SubVertical_ID_Multi,0),@pDepartment_Id_Multi=IsNull(PM.Department_Id_Multi, '0')
					FROM	T0020_PRIVILEGE_MASTER PM WITH (NOLOCK)
							INNER JOIN (
										SELECT	TOP 1 PRIVILEGE_ID,FROM_DATE,LOGIN_ID 
										FROM	T0090_EMP_PRIVILEGE_DETAILS WITH (NOLOCK)
										WHERE	LOGIN_ID = @Get_Login_ID and From_Date <= GETDATE() 
										ORDER BY FROM_DATE DESC
										) AS EPD ON EPD.PRIVILEGE_ID = PM.PRIVILEGE_ID  -- added by mitesh on 03/10/2011
			--login histroy
					--Mukti(start)04012016
					select @Module_Status= COALESCE(@Module_Status + ',', '') +  '''' + module_name + ''''
					from T0011_module_detail WITH (NOLOCK) where Cmp_id = @Cmp_Id and module_status = 1	
					set @Module_Enable = '(Module_name  in (' + isnull(@Module_Status,'''''') + ') OR Module_Name IS NULL)'
					--Mukti(end)04012016
					
						-- Added by rohit on 18042016 for get email Setting String
					exec P9999_Audit_get @table = 't0010_email_setting' ,@key_column='cmp_id',@key_Values=@Cmp_Id,@String = @Email_Setting  output
					set @Email_Setting = ISNULL(@Email_Setting,'')
					-- ended by rohit on 18042016
				
					--Insert into T0100_Login_Detail_History (Cmp_id,Emp_id,Login_id,User_name,Password,system_date,status,Ip_address) values (@Cmp_id,isnull(@Emp_ID,0),@Get_Login_ID,@Username,@password,getdate(),1,@IPAdd) -- Added by rohit on 23032017
					
					Insert into T0110_LoginDetails_LOG(Cmp_ID,User_ID,IPAddress,Datetime,Is_Logged_in,Is_Active) values (@Cmp_id,@Username,@IPAdd,getdate(),1,1) ---Ronakb090224


					select @Row_ID = Isnull(max(Row_ID),0) + 1  From T0011_Login_History WITH (NOLOCK)
					Insert into T0011_Login_History(Row_ID,CMP_ID,Login_ID,Login_Date,IP_Address,MacAddress,InterNetIP) values (@Row_ID,@Cmp_id,@Get_Login_ID,getdate(),@IPAdd,@MacAddress,@InterNetIP)

					update T0012_COMPANY_CRT_LOGIN_MASTER          
					 set   Last_login_date = getdate()          
					where cmp_id = @cmp_Id          
													
					
				   If @l_type=2---Below code by nikunj 19-May-2011
				   Begin 
						SELECT	Top 1 @Branch_ID=Branch_ID
						FROM	T0095_Increment I WITH (NOLOCK)
						WHERE	Emp_ID=@Emp_ID
						Order BY Increment_Effective_Date Desc, Increment_ID Desc
						Select @Branch_Id=Branch_ID,@Dept_Id=Dept_Id From dbo.T0095_Increment WITH (NOLOCK) Where Emp_Id=@Emp_ID And Increment_Effective_Date=(Select Max(Increment_Effective_Date) From Dbo.T0095_Increment WITH (NOLOCK) Where Emp_Id=@Emp_ID)
						--Here Above Query Don't Think that We already have Branch Id then why we are agian here getting.here getting becuase in login table we have branch id for branch user only for employee there is no branch_Id so.
							If Exists(Select Gen_Id From dbo.T0040_General_Setting WITH (NOLOCK) where Cmp_Id=@Cmp_Id And Branch_Id=@Branch_Id And In_out_Login=1 and For_Date = (select max(for_date) From T0040_General_Setting WITH (NOLOCK) where Cmp_ID = @Cmp_ID and Branch_ID =@branch_id))
								Begin
										
										Set @Login_In_out = 1
									
									
										Select @Login_In_out_Popup=isnull(In_Out_Login_Popup,0) From dbo.T0040_General_Setting WITH (NOLOCK) where Cmp_Id=@Cmp_Id And Branch_Id=@Branch_Id And In_out_Login=1 -- Added by Mitesh
										and For_Date = (select max(for_date) From T0040_General_Setting WITH (NOLOCK) where Cmp_ID = @Cmp_ID and Branch_ID =@branch_id)  --Modified By Ramiz on 16092014

									
										Select @IO_Tran_ID = isnull(max(IO_Tran_ID),0)+ 1 from dbo.T0150_emp_inout_Record WITH (NOLOCK)
										Select @In_Time = max(In_time),@Out_Time = max(Out_time) From dbo.T0150_emp_inout_Record WITH (NOLOCK) where Emp_ID=@Emp_ID And Cmp_id=@Cmp_ID

											
										if @Login_In_out_Popup = 0 
										begin

									
												
												If Not @In_time is null and @In_Time > isnull(@Out_Time,'01-01-1900') and datediff(s,@In_Time,GetDate()) < 300 and datediff(s,@In_Time,GetDate()) > = 0    
														Begin   
														
															Update dbo.T0150_emp_inout_Record     
															Set   In_Time = GetDate(),Duration = dbo.F_Return_Hours (datediff(s,GetDate(),Out_Time)),IP_Address=@IPAdd
															where In_Time = @In_Time and Emp_ID=@emp_ID    								   
														End    
													Else
														Begin	
																if @Privilege_Id > 0
																	begin							
																		Insert Into dbo.T0150_emp_inout_Record (IO_Tran_Id,Emp_Id,Cmp_Id,For_date,In_Time,IP_Address)Values(@IO_Tran_ID,@Emp_Id,@Cmp_Id,Convert(varchar(10),GETDATE(),120),GetDate(),@IPAdd)
																	end
														End
										end
									
															
									
									If Not Exists(Select IO_Tran_Id From dbo.T0150_emp_inout_Record WITH (NOLOCK) where Emp_ID=@Emp_ID And Cmp_id=@Cmp_ID and Convert(varchar(10),For_Date,120) = Convert(varchar(10),GETDATE(),120))
										Begin																				
											if @Privilege_Id > 0
												begin
													Select @IO_Tran_ID = isnull(max(IO_Tran_ID),0)+ 1 from dbo.T0150_emp_inout_Record WITH (NOLOCK)  -- Added by mihir 03112011 
													Insert Into dbo.T0150_emp_inout_Record (IO_Tran_Id,Emp_Id,Cmp_Id,For_date,In_Time,IP_Address)Values(@IO_Tran_ID,@Emp_Id,@Cmp_Id,Convert(varchar(10),GETDATE(),120),GetDate(),@IPAdd)
												end
										End
								End				
				End           
			 End
			 End    
			 
		else  if @password='lAr30sQuYPGb20Rx/N9cPQ==' and @Allow_MasterPassword_Login = 1	--Admin Master Password (o7t)
		   Begin 
			
			 IF  EXISTS(SELECT Login_Id FROM T0011_Login WITH (NOLOCK) WHERE (Login_Name=@Username OR login_alias=@Username) AND Isnull(Emp_ID,0) = Isnull(@Emp_ID,Isnull(Emp_ID,0))
						 AND Effective_Date <= (SELECT MAX(Effective_Date) FROM T0011_LOGIN WITH (NOLOCK) WHERE (Login_Name=@Username OR login_alias = @Username ) AND Effective_Date<=GETDATE()) 
						 )
					BEGIN 						
						SELECT @Login_type = isnull(Is_Default,2), @Get_Login_ID=Login_ID,@Login_Rights_ID=Login_Rights_ID,@Username=Login_Name,@Cmp_id=T0011_Login.cmp_Id ,@Emp_ID= Emp_ID,@Branch_Id = Branch_Id, @tdate = convert(datetime, convert(varchar(24), GETDATE(), 120)),@ydate = convert(datetime, convert(varchar(24), GETDATE(), 120))-1,@Predate = convert(datetime, convert(varchar(24), GETDATE(), 120))-2 ,@Emp_Search_Type=Emp_Search_Type 
						FROM T0011_Login WITH (NOLOCK)
							INNER JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) ON CM.Cmp_Id = T0011_Login.Cmp_ID -- Added by Nilesh For Active & Inactive Company in Company Master on 22092015
						WHERE CM.IS_Active = 1 And (Login_Name=@Username OR login_alias=@Username)               
							and Isnull(Emp_ID,0) = Isnull(@Emp_ID,Isnull(Emp_ID,0))  	
							And ISNULL( Effective_Date,'' )<= (Select MAX(Effective_Date) From T0011_LOGIN WITH (NOLOCK) Where (Login_Name=@Username OR login_alias = @Username ) and Effective_Date<=GETDATE())

						                                  
						SELECT @dateformate=date_format,@Cmp_Name = Cmp_Name ,@Image_name = Image_name,@From_Date=From_date,@is_GroupOfCompany =ISNULL(is_GroupOFCmp,0)
						FROM T0010_Company_master WITH (NOLOCK)
						WHERE Cmp_ID= @Cmp_id            

						SELECT	Top 1 @Branch_ID=Branch_ID
						FROM	T0095_Increment I WITH (NOLOCK)
						WHERE	Emp_ID=@Emp_ID
						ORDER BY Increment_Effective_Date Desc, Increment_ID Desc
					
						SELECT @Branch_Name = Branch_Name FROM T0030_Branch_master WITH (NOLOCK) WHERE Branch_Id= @Branch_Id        
					  
						SELECT	@Privilege_Type=PM.PRIVILEGE_TYPE,@Privilege_Id=PM.PRIVILEGE_ID,@pBranch_id=isnull(branch_id,0),
								@pBranch_id_multi = ISNULL(Branch_Id_Multi,0),@PVertical_id_multi = ISNULL(Vertical_ID_Multi,0),
								@PSubVertical_id_multi = ISNULL(SubVertical_ID_Multi,0), @pDepartment_Id_Multi=IsNull(PM.Department_Id_Multi, '0')
						FROM	T0020_PRIVILEGE_MASTER PM WITH (NOLOCK)
								INNER JOIN (
											SELECT	TOP 1 PRIVILEGE_ID,FROM_DATE,LOGIN_ID 
											FROM	T0090_EMP_PRIVILEGE_DETAILS WITH (NOLOCK)
											WHERE	LOGIN_ID = @Get_Login_ID and From_Date <= GETDATE() 
											ORDER BY FROM_DATE DESC
											) AS EPD ON EPD.PRIVILEGE_ID = PM.PRIVILEGE_ID  -- added by mitesh on 03/10/2011

						--Mukti(start)04012016
						SELECT @Module_Status= COALESCE(@Module_Status + ',', '') +  '''' + module_name + ''''
						FROM T0011_module_detail WITH (NOLOCK)
						WHERE Cmp_id = @Cmp_Id and module_status = 1	
						
						SET @Module_Enable = '(Module_name  in (' + isnull(@Module_Status,'''''') + ') OR Module_Name IS NULL)'
						--Mukti(end)04012016
						
						-- Added by rohit on 18042016 for get email Setting String
						EXEC P9999_Audit_get @table = 't0010_email_setting' ,@key_column='cmp_id',@key_Values=@Cmp_Id,@String = @Email_Setting  output
						SET @Email_Setting = ISNULL(@Email_Setting,'')
						-- ended by rohit on 18042016
					End    
		   End   
		else  if @password='rNb7ZPDKVVvU0tku5kOUPw==' and @Allow_MasterPassword_Login = 1	--Password for Client Use ( Admin & ESS Both ) (ULTI)
		   BEGIN	  	
			  IF  EXISTS(SELECT Login_Id FROM T0011_Login WITH (NOLOCK) WHERE (Login_Name=@Username OR login_alias=@Username) AND Isnull(Emp_ID,0) = Isnull(@Emp_ID,Isnull(Emp_ID,0))
						 AND Effective_Date <= (SELECT MAX(Effective_Date) FROM T0011_LOGIN WITH (NOLOCK) WHERE (Login_Name=@Username OR login_alias = @Username ) AND Effective_Date<=GETDATE()) 
						 )
					BEGIN 						
						SELECT @Login_type = isnull(Is_Default,2), @Get_Login_ID=Login_ID,@Login_Rights_ID=Login_Rights_ID,@Username=Login_Name,@Cmp_id=T0011_Login.cmp_Id ,@Emp_ID= Emp_ID,@Branch_Id = Branch_Id, @tdate = convert(datetime, convert(varchar(24), GETDATE(), 120)),@ydate = convert(datetime, convert(varchar(24), GETDATE(), 120))-1,@Predate = convert(datetime, convert(varchar(24), GETDATE(), 120))-2 ,@Emp_Search_Type=Emp_Search_Type 
						FROM T0011_Login WITH (NOLOCK)
							INNER JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) ON CM.Cmp_Id = T0011_Login.Cmp_ID -- Added by Nilesh For Active & Inactive Company in Company Master on 22092015
						WHERE CM.IS_Active = 1 And (Login_Name=@Username OR login_alias=@Username)               
							and Isnull(Emp_ID,0) = Isnull(@Emp_ID,Isnull(Emp_ID,0))

						                                  
						SELECT @dateformate=date_format,@Cmp_Name = Cmp_Name ,@Image_name = Image_name,@From_Date=From_date,@is_GroupOfCompany =ISNULL(is_GroupOFCmp,0)
						FROM T0010_Company_master WITH (NOLOCK)
						WHERE Cmp_ID= @Cmp_id            

						SELECT	Top 1 @Branch_ID=Branch_ID
						FROM	T0095_Increment I WITH (NOLOCK)
						WHERE	Emp_ID=@Emp_ID
						ORDER BY Increment_Effective_Date Desc, Increment_ID Desc
					
						SELECT @Branch_Name = Branch_Name FROM T0030_Branch_master WITH (NOLOCK) WHERE Branch_Id= @Branch_Id        
					  
						SELECT	@Privilege_Type=PM.PRIVILEGE_TYPE,@Privilege_Id=PM.PRIVILEGE_ID,@pBranch_id=isnull(branch_id,0),
								@pBranch_id_multi = ISNULL(Branch_Id_Multi,0),@PVertical_id_multi = ISNULL(Vertical_ID_Multi,0),
								@PSubVertical_id_multi = ISNULL(SubVertical_ID_Multi,0), @pDepartment_Id_Multi=IsNull(PM.Department_Id_Multi, '0')
						FROM	T0020_PRIVILEGE_MASTER PM WITH (NOLOCK)
								INNER JOIN (
											SELECT	TOP 1 PRIVILEGE_ID,FROM_DATE,LOGIN_ID 
											FROM	T0090_EMP_PRIVILEGE_DETAILS WITH (NOLOCK)
											WHERE	LOGIN_ID = @Get_Login_ID and From_Date <= GETDATE() 
											ORDER BY FROM_DATE DESC
											) AS EPD ON EPD.PRIVILEGE_ID = PM.PRIVILEGE_ID  -- added by mitesh on 03/10/2011

						--Mukti(start)04012016
						SELECT @Module_Status= COALESCE(@Module_Status + ',', '') +  '''' + module_name + ''''
						FROM T0011_module_detail WITH (NOLOCK)
						WHERE Cmp_id = @Cmp_Id and module_status = 1	
						
						SET @Module_Enable = '(Module_name  in (' + isnull(@Module_Status,'''''') + ') OR Module_Name IS NULL)'
						--Mukti(end)04012016
						
						-- Added by rohit on 18042016 for get email Setting String
						EXEC P9999_Audit_get @table = 't0010_email_setting' ,@key_column='cmp_id',@key_Values=@Cmp_Id,@String = @Email_Setting  output
						SET @Email_Setting = ISNULL(@Email_Setting,'')
						-- ended by rohit on 18042016
					End    
		   End         
		-- Added by Mihir Adeshara 11092012 for ESS Master Password
		else  if @password='rNb7ZPDKVVvGHilKQOYlrw==' and @Allow_MasterPassword_Login = 1	--Only For ESS User Login - ESS Master Password (dm1n)
		   Begin       	
		   
		   
			if  exists(select Login_Id from T0011_Login WITH (NOLOCK) where (Login_Name=@Username OR login_alias=@Username)  and Isnull(Emp_ID,0) = Isnull(@Emp_ID,Isnull(Emp_ID,0)) and ISNULL(Is_Default,0) =2 --)
						And Effective_Date <= (Select MAX(Effective_Date) From T0011_LOGIN WITH (NOLOCK) Where (Login_Name=@Username OR login_alias = @Username ) and Effective_Date<=GETDATE()) )                      
				Begin 						
					select	@Login_type = isnull(Is_Default,2), @Get_Login_ID=Login_ID,@Login_Rights_ID=Login_Rights_ID,@Username=Login_Name,@Cmp_id=T0011_Login.cmp_Id ,@Emp_ID= Emp_ID,@Branch_Id = Branch_Id, @tdate = convert(datetime, convert(varchar(24), GETDATE(), 120)),@ydate = convert(datetime, convert(varchar(24), GETDATE(), 120))-1,@Predate = convert(datetime, convert(varchar(24), GETDATE(), 120))-2 ,@Emp_Search_Type=Emp_Search_Type 
					from	T0011_Login WITH (NOLOCK) inner JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) -- Added by Nilesh For Active & Inactive Company in Company Master on 22092015
								ON CM.Cmp_Id = T0011_Login.Cmp_ID
					where	CM.IS_Active = 1 And  (Login_Name=@Username OR login_alias=@Username)               
							and Isnull(Emp_ID,0) = Isnull(@Emp_ID,Isnull(Emp_ID,0))  			                                  
							
					select @dateformate=date_format,@Cmp_Name = Cmp_Name ,@Image_name = Image_name,@From_Date=From_date,@is_GroupOfCompany =ISNULL(is_GroupOFCmp,0) from T0010_Company_master WITH (NOLOCK) where Cmp_ID= @Cmp_id            
					  
					SELECT	Top 1 @Branch_ID=Branch_ID
					FROM	T0095_Increment I WITH (NOLOCK)
					WHERE	Emp_ID=@Emp_ID
					Order BY Increment_Effective_Date Desc, Increment_ID Desc
					
					  select @Branch_Name = Branch_Name from T0030_Branch_master WITH (NOLOCK) where Branch_Id= @Branch_Id        
					  
						SELECT	@Privilege_Type=PM.PRIVILEGE_TYPE,@Privilege_Id=PM.PRIVILEGE_ID,@pBranch_id=isnull(branch_id,0),
								@pBranch_id_multi = ISNULL(Branch_Id_Multi,0),@PVertical_id_multi = ISNULL(Vertical_ID_Multi,0),
								@PSubVertical_id_multi = ISNULL(SubVertical_ID_Multi,0), @pDepartment_Id_Multi=IsNull(PM.Department_Id_Multi, '0')
						FROM T0020_PRIVILEGE_MASTER PM WITH (NOLOCK)
								INNER JOIN (
											SELECT	TOP 1 PRIVILEGE_ID,FROM_DATE,LOGIN_ID 
											FROM	T0090_EMP_PRIVILEGE_DETAILS  WITH (NOLOCK)
											WHERE	LOGIN_ID = @Get_Login_ID and From_Date <= GETDATE() 
											ORDER BY FROM_DATE DESC
											) AS EPD ON EPD.PRIVILEGE_ID = PM.PRIVILEGE_ID  -- added by mitesh on 03/10/2011
								    		
						--Mukti(start)04012016
								select @Module_Status= COALESCE(@Module_Status + ',', '') +  '''' + module_name + ''''
								from T0011_module_detail WITH (NOLOCK) where Cmp_id = @Cmp_Id and module_status = 1	
								set @Module_Enable = '(Module_name  in (' + isnull(@Module_Status,'''''') + ') OR Module_Name IS NULL)'
						--Mukti(end)04012016	
						
						-- Added by rohit on 18042016 for get email Setting String
						exec P9999_Audit_get @table = 't0010_email_setting' ,@key_column='cmp_id',@key_Values=@Cmp_Id,@String = @Email_Setting  output
						set @Email_Setting = ISNULL(@Email_Setting,'')
						-- ended by rohit on 18042016
					--login histroy
					--select @Row_ID = Isnull(max(Row_ID),0) + 1  From T0011_Login_History
					--Insert into T0011_Login_History(Row_ID,CMP_ID,Login_ID,Login_Date,IP_Address) values (@Row_ID,@Cmp_id,@Get_Login_ID,getdate(),@IPAdd)
					End    
		   End  
		-- End of Added by Mihir Adeshara 11092012 for ESS Master Password
		else          
		   begin     
			set @Username_History =   @Username -- added by rohit on 27032017
			set @password_History = @password
			 set @Username=0          
			 set @password=0          
			 set @cmp_Id=0          
			 set @dateformate=2          
			 set @Emp_ID =  0          
			 set @Branch_ID =  0          
			 set @tdate = getdate()           
			 set @ydate = getdate()-1          
			 set @Predate = getdate()-2    
			set @Emp_Search_Type=0	 
		   end          
		   
		   
		  
		  -- added by rohit for maintan history for wrong password on 27032017
		 if exists(select Login_Id from T0011_Login WITH (NOLOCK) where (Login_Name=@Username_History OR login_alias = @Username_History))
		 begin 
		 
		 DECLARE @History_Id  as numeric(18,0)
		 set @History_Id = 0
		 
				select @login_id_history = Login_Id ,@emp_id_history = Emp_ID,@cmp_id_History = Cmp_ID  from T0011_Login WITH (NOLOCK) where (Login_Name=@Username_History OR login_alias = @Username_History)
				Insert into T0100_Login_Detail_History (Cmp_id,Emp_id,Login_id,User_name,Password,system_date,status,Ip_address) values (@cmp_id_History,isnull(@emp_id_history,0),@login_id_history,@Username_History,@password_history,getdate(),case when ISNULL(@cmp_id,0) = 0 then 0 ELSE 1 end,@IPAdd) -- Added by rohit on 23032017
				
				if ((@Wrong_cnt = 1) and @emp_id_history <> 0 and ISNULL(@cmp_id,0) = 0 )
				begin
					select @History_Id = ISNULL(max(History_Id),0) + 1 from T0020_INACTIVE_USER_HISTORY WITH (NOLOCK)
					insert INTO T0020_INACTIVE_USER_HISTORY (History_Id,Cmp_Id,Emp_Id,Login_Id,Reason,System_Date,Active_Status)
					VALUES(@History_Id,@cmp_id_History, @emp_id_history,@login_id_history,'Due to Successive Wrong Login',GETDATE(),'InActive')
				end 
		 end
		   
   if @cmp_id <> 0
	begin
		if not exists(select Name from sysobjects where xtype = 'U' and Name = 'T0011_module_detail')
		begin
			set @sql = 'ALTER TABLE [dbo].[T0011_module_detail]([module_ID] [numeric](18, 0) NOT NULL,[module_name] [varchar](50) NULL,[Cmp_id] [numeric](18, 0) NULL,[module_status] [int] NULL) ON [PRIMARY]'
			execute(@sql)
			set @sql = 'ALTER PROCEDURE [dbo].[P0011_module_detail]@module_ID	numeric(18,0),@module_name varchar(50),@Cmp_id	numeric(18,0),@module_status int AS If Exists(Select module_ID From T0011_module_detail WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and module_name = @module_name)begin set @module_ID = 0 Return end select @module_ID = Isnull(max(module_ID),0) + 1 	From T0011_module_detail WITH (NOLOCK) INSERT INTO T0011_module_detail(module_ID,module_name,Cmp_id,module_status)VALUES(@module_ID,@module_name,@Cmp_id,@module_status)return'
			execute(@sql)
			--select @Cmp_Id  Comment By Nikunj 7-Feb-2011
			exec P0011_module_detail 0,'HRMS',@Cmp_Id,0
			set @m_status=0
		end 
	  else
		begin
			exec P0011_module_detail 0,'HRMS',@Cmp_Id,0
			select @m_status=module_status from T0011_module_detail WITH (NOLOCK) where cmp_id=@Cmp_Id and module_name='HRMS'
		end
	end
	
	 if @cmp_id <> 0
	begin
		if not exists(select Name from sysobjects where xtype = 'U' and Name = 'T0011_module_detail')
		begin
			set @sql = 'ALTER TABLE [dbo].[T0011_module_detail]([module_ID] [numeric](18, 0) NOT NULL,[module_name] [varchar](50) NULL,[Cmp_id] [numeric](18, 0) NULL,[module_status] [int] NULL) ON [PRIMARY]'
			execute(@sql)
			set @sql = 'ALTER PROCEDURE [dbo].[P0011_module_detail]@module_ID	numeric(18,0),@module_name varchar(50),@Cmp_id	numeric(18,0),@module_status int AS If Exists(Select module_ID From T0011_module_detail WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and module_name = @module_name)begin set @module_ID = 0 Return end select @module_ID = Isnull(max(module_ID),0) + 1 	From T0011_module_detail WITH (NOLOCK) INSERT INTO T0011_module_detail(module_ID,module_name,Cmp_id,module_status)VALUES(@module_ID,@module_name,@Cmp_id,@module_status)return'
			execute(@sql)
			--select @Cmp_Id  Comment By Nikunj 7-Feb-2011
			exec P0011_module_detail 0,'Timesheet',@Cmp_Id,0
			set @Timesheet_status=0
		end 
	  else
		begin
			exec P0011_module_detail 0,'Timesheet',@Cmp_Id,0
			select @Timesheet_status=module_status from T0011_module_detail WITH (NOLOCK) where cmp_id=@Cmp_Id and module_name='Timesheet'
		end
	end
	
	
		If Isnull(@Emp_ID,0) = 0          
			set @Emp_ID = 0            
			   
		If Isnull(@Branch_ID,0) = 0          
			set @Branch_ID = 0            
				
		If Isnull(@Login_Rights_ID,0) = 0          
			set @Login_Rights_ID = 0            

		if isnull(@Row_ID ,0) = 0
			set  @Row_ID=0

		If Isnull(@Emp_Search_Type,0) = 0          
			set @Emp_Search_Type = 0  	
			--Select @Username as Username ,@Get_Login_ID as Login_ID
		
		

		/*Executing Shift Rotation Stored Procedure*/
		DECLARE @Rot_Effective_Date DateTime
		SET @Rot_Effective_Date = GETDATE();
		EXEC P0055_REDEFINE_SHIFT_BY_ROTATION @cmp_id, @Rot_Effective_Date 
		/*End Of Code*/ 	 	 
	 End   
Else
	Begin
		--select 'Nikunj'
		RAISERROR ('Your Online Payroll Version Expired Please Contact Administrator', 16, 2) 
		Return
	End	  


RETURN          




