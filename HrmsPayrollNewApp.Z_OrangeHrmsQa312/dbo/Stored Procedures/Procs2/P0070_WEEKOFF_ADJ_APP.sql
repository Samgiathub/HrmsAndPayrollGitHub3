

---25/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0070_WEEKOFF_ADJ_APP]
	  @W_Tran_ID int output
	 ,@Cmp_ID int
	 ,@Emp_Tran_ID bigint
     ,@Emp_Application_ID int
	 ,@For_Date datetime
	 ,@Weekoff_Day varchar(250)
	 ,@Weekoff_Day_value varchar(250)
	 ,@Alt_W_name varchar(100)
	 ,@Alt_W_Full_Day_Cont varchar(100)
	 ,@Alt_W_Half_Day_Cont varchar(100)
	 ,@Is_P_Comp		tinyint
	 ,@tran_type char
	 ,@User_Id int = 0 
	 ,@IP_Address varchar(30)= '' 
	 ,@Approved_Emp_ID int
	,@Approved_Date datetime = Null
	,@Rpt_Level int 
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

					-- Added for Audit Trail by Ali 09102013 -- Start
					Declare @Old_Emp_Name as varchar(200)
					Declare @Old_Emp_Id int
					Declare @Old_Branch_Name as varchar(100)
					Declare @New_Branch_Name as varchar(100)
					Declare @Old_For_Date as datetime
					Declare @Old_Weekoff_Day varchar(250)
					Declare @Oldvalue as varchar(max)
										
					Set @Old_Emp_Name = ''
					Set @Old_Emp_Id = 0
					Set @Old_Branch_Name = ''
					Set @New_Branch_Name = ''
					Set @Old_For_Date = null
					Set @Old_Weekoff_Day = ''
					Set @Oldvalue = ''
					-- Added for Audit Trail by Ali 09102013 -- End
		
		--- Added By Ali 13122013 Start ---
		
		  Declare @Sal_St_Date Datetime        
		  Declare @Sal_end_Date Datetime      
		  Declare @manual_salary_Period as int
		  set @manual_salary_Period = 0
		  Declare @Salary_Cycle_id as numeric 
		  set @Salary_Cycle_id  = 0    
		  declare @is_salary_cycle_emp_wise as tinyint   
		  set @is_salary_cycle_emp_wise = 0  
		  Declare @TempFromDate datetime
		  Declare @TempToDate datetime
		  
		  
          Declare @From_Date datetime
		  Declare @To_Date datetime
		  /* commented binal not need
		  select @is_salary_cycle_emp_wise = isnull(Setting_Value,0) from T0040_SETTING where Cmp_ID = @Cmp_ID and Setting_Name = 'Salary Cycle Employee Wise'    
		  		    
		  IF @is_salary_cycle_emp_wise = 1    
			BEGIN  
				  SELECT @Salary_Cycle_id = SalDate_id from T0095_Emp_Salary_Cycle 
				  where Emp_id = @Emp_ID AND Effective_date in    
				  (SELECT max(effective_date) as effective_date from T0095_Emp_Salary_Cycle     
				  where Emp_id = @Emp_ID AND Effective_date <=  @For_Date    
				  GROUP by Emp_id)          
				  SELECT @Sal_St_Date = Salary_st_date FROM T0040_Salary_Cycle_Master 
				  where Tran_Id = @Salary_Cycle_id   
				  
		   END  
		   ELSE  
		   BEGIN  
				  select Top 1 @Sal_St_Date = Sal_st_Date ,@manual_salary_Period= isnull(manual_salary_Period ,0)
				  from T0040_GENERAL_SETTING where cmp_ID = @cmp_ID        
				  and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING 
				  where For_Date <= @For_Date and Cmp_ID = @Cmp_ID)        
		   END  
		  
		  if isnull(@Sal_St_Date,'') = ''          
			 begin           
				  set @From_Date  = @TempFromDate           
				  set @To_Date = @TempToDate          
			 end           
			 else if day(@Sal_St_Date) =1        
			 begin          
				  set @From_Date  = @TempFromDate           
				  set @To_Date = @TempToDate          
			 end           
			 else  if @Sal_St_Date <> ''  and day(@Sal_St_Date) > 1         
			 begin               
			   if @manual_salary_Period = 0       
			   Begin  
					If DATENAME(dd,@Sal_St_Date) <= Datename(dd,@For_Date) -- Added this condition by Hardik 01/11/2014
						Begin
							set @Sal_St_Date =  cast(cast(day(@Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,@For_Date) as varchar(10)) + '-' +  cast(year(@For_Date)as varchar(10)) as smalldatetime)          
							set @Sal_End_Date = dateadd(d,-1,dateadd(m,1,@Sal_St_Date))       
						End
					Else
						Begin
							set @Sal_St_Date =  cast(cast(day(@Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,dateadd(m,-1,@For_Date)) as varchar(10)) + '-' +  cast(year(dateadd(m,-1,@For_Date) )as varchar(10)) as smalldatetime)          
							set @Sal_End_Date = dateadd(d,-1,dateadd(m,1,@Sal_St_Date))       
						End

					Set @From_Date = @Sal_St_Date      
					Set @To_Date = @Sal_End_Date  
				end      
			  else      
			   begin         
				    select @Sal_St_Date=from_date,@Sal_End_Date=end_date from salary_period where Month(from_date) = Month(@For_Date) And Year(from_date) = Year(@For_Date)
				    Set @From_Date = @Sal_St_Date      
					Set @To_Date = @Sal_End_Date          
			   End       
		  End  
 		
		
		--if Exists(Select 1 from T0200_MONTHLY_SALARY where Emp_ID=@Emp_Id and  Month_End_Date >= @To_Date and Cmp_ID = @Cmp_ID) 
		--		Begin
		--			RAISERROR ('Months Salary Exists', 16, 2) 
		--			return 
		--		End
		*/		
				

		If @tran_type ='I' 
			begin
			if exists (Select W_Tran_ID  from T0070_WEEKOFF_ADJ_APP WITH (NOLOCK)
				Where Emp_Tran_ID=@Emp_Tran_ID and Emp_Application_ID=@Emp_Application_ID and Cmp_ID = @Cmp_ID AND Approved_Date=@For_Date) 
				begin
				
				
						Select @W_Tran_ID = W_Tran_ID  from T0070_WEEKOFF_ADJ_APP WITH (NOLOCK)
						Where Emp_Tran_ID=@Emp_Tran_ID and Emp_Application_ID=@Emp_Application_ID and Cmp_ID = @Cmp_ID 
						AND Approved_Date=@For_Date
						
								/* commented binal not need
									Select 
									@Old_Emp_Id = Emp_ID
									,@Old_For_Date = For_Date
									,@Old_Weekoff_Day = Weekoff_Day
									From T0070_WEEKOFF_ADJ_APP Where W_Tran_ID = @W_Tran_ID
										
									Set @Old_Emp_Name = (Select ISNULL(Alpha_Emp_Code,'') + ' - ' + ISNULL(Emp_Full_Name,'')   from T0060_EMP_MASTER_APP Where Emp_ID =  @Old_Emp_Id)
									Set @Old_Branch_Name = (select Branch_Name from V0080_Employee_Master where Cmp_ID = @Cmp_ID and Emp_ID = @Old_Emp_Id)													
								*/
								
								
						Update  T0070_WEEKOFF_ADJ_APP 
						Set		Weekoff_Day		= @Weekoff_Day,
								
								Weekoff_Day_Value = @Weekoff_Day_Value,
								Alt_W_name = @Alt_W_name,
								Alt_W_Full_Day_Cont =@Alt_W_Full_Day_Cont,
								Alt_W_Half_Day_Cont=@Alt_W_Half_Day_Cont,
								Is_P_Comp=@Is_P_Comp,
								Approved_Emp_ID=@Approved_Emp_ID,
								Approved_Date=@For_Date,
								Rpt_Level=@Rpt_Level
						where	W_Tran_ID = @W_Tran_ID and Cmp_ID = @Cmp_ID 
						
								/* commented binal not need
								Set @Old_Emp_Name = (Select ISNULL(Alpha_Emp_Code,'') + ' - ' + ISNULL(Emp_Full_Name,'')   from T0060_EMP_MASTER_APP Where Emp_ID =  @Emp_ID)
								Set @New_Branch_Name = (select Branch_Name from V0080_Employee_Master where Cmp_ID = @Cmp_ID and Emp_ID = @Emp_ID)
								set @OldValue = 'old Value' + '#'+ 'Employee Name :' + ISNULL( @Old_Emp_Name,'') 
												+ '#' + 'Branch abc Name :' + ISNULL(@Old_Branch_Name,'') 												
												+ '#' + 'Effective Date :' + cast(ISNULL(@Old_For_Date,'') as nvarchar(11)) 
												+ '#' + 'Off Day :' + ISNULL(@Old_Weekoff_Day,'')
												+ '#' + 
												'New Value' + '#'+ 'Employee Name :' + ISNULL( @Old_Emp_Name,'') 
												+ '#' + 'Branch abc Name :' + ISNULL(@New_Branch_Name,'') 												
												+ '#' + 'Effective Date :' + cast(ISNULL(@For_Date,'') as nvarchar(11)) 
												+ '#' + 'Off Day :' + ISNULL(@Weekoff_Day,'')
												
								exec P9999_Audit_Trail @Cmp_ID,'U','Employee Weekoff',@Oldvalue,@Emp_ID,@User_Id,@IP_Address,1
								*/
						

					
				end
			else
				begin
				
					Select @W_Tran_ID = isnull(max(W_Tran_ID),0) + 1  from T0070_WEEKOFF_ADJ_APP WITH (NOLOCK)
					Insert Into T0070_WEEKOFF_ADJ_APP(W_Tran_ID,Cmp_ID,Emp_Tran_ID,Emp_Application_ID,Weekoff_Day,Weekoff_Day_Value,Alt_W_name,Alt_W_Full_Day_Cont,Alt_W_Half_Day_Cont,Is_P_Comp,Approved_Emp_ID,Approved_Date,Rpt_Level)
					values(@W_Tran_ID,@Cmp_ID,@Emp_Tran_ID,@Emp_Application_ID,@Weekoff_Day,@Weekoff_Day_Value,@Alt_W_name,@Alt_W_Full_Day_Cont,@Alt_W_Half_Day_Cont,@Is_P_Comp,@Approved_Emp_ID,@Approved_Date,@Rpt_Level)
					
								/* commented binal not need
								Set @Old_Emp_Name = (Select ISNULL(Alpha_Emp_Code,'') + ' - ' + ISNULL(Emp_Full_Name,'')   from T0060_EMP_MASTER_APP Where Emp_ID = @Emp_ID)
								Set @Old_Branch_Name = (select Branch_Name from V0080_Employee_Master where Cmp_ID = @Cmp_ID and Emp_ID = @Emp_ID)
								
								set @OldValue = 'New Value' + '#'+ 'Employee Name :' + ISNULL( @Old_Emp_Name,'') 
													+ '#' + 'Branch abc Name :' + ISNULL(@Old_Branch_Name,'') 												
													+ '#' + 'Effective Date :' + cast(ISNULL(@For_Date,'') as nvarchar(11)) 
													+ '#' + 'Off Day :' + ISNULL(@Weekoff_Day,'') 												
														
								exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'Employee Weekoff',@Oldvalue,@Emp_ID,@User_Id,@IP_Address,1												
								*/
										
				end 
			end
		else if @tran_type ='U' 
			begin
			
								/* commented binal not need
									Select 
									@Old_Emp_Id = Emp_ID
									,@Old_For_Date = For_Date
									,@Old_Weekoff_Day = Weekoff_Day
									From T0070_WEEKOFF_ADJ_APP Where W_Tran_ID = @W_Tran_ID
										
									Set @Old_Emp_Name = (Select ISNULL(Alpha_Emp_Code,'') + ' - ' + ISNULL(Emp_Full_Name,'')   from T0060_EMP_MASTER_APP Where Emp_ID =  @Old_Emp_Id)
									Set @Old_Branch_Name = (select Branch_Name from V0080_Employee_Master where Cmp_ID = @Cmp_ID and Emp_ID = @Old_Emp_Id)													
								
						        */
					
				Update	T0070_WEEKOFF_ADJ_APP 
				Set		Weekoff_Day	= @Weekoff_Day,
						
						Weekoff_Day_Value = @Weekoff_Day_Value,
						Alt_W_name = @Alt_W_name,
						Alt_W_Full_Day_Cont =@Alt_W_Full_Day_Cont,
						Alt_W_Half_Day_Cont=@Alt_W_Half_Day_Cont,
						Is_P_Comp=@Is_P_Comp,
						Approved_Emp_ID=@Approved_Emp_ID,
						Approved_Date=@For_Date,
						Rpt_Level=@Rpt_Level
				where	W_Tran_ID = @W_Tran_ID and Cmp_ID = @Cmp_ID 
				
								/* commented binal not need
								Set @Old_Emp_Name = (Select ISNULL(Alpha_Emp_Code,'') + ' - ' + ISNULL(Emp_Full_Name,'')   from T0060_EMP_MASTER_APP Where Emp_ID =  @Emp_ID)
								Set @New_Branch_Name = (select Branch_Name from V0080_Employee_Master where Cmp_ID = @Cmp_ID and Emp_ID = @Emp_ID)
								set @OldValue = 'old Value' + '#'+ 'Employee Name :' + ISNULL( @Old_Emp_Name,'') 
												+ '#' + 'Branch abc Name :' + ISNULL(@Old_Branch_Name,'') 												
												+ '#' + 'Effective Date :' + cast(ISNULL(@Old_For_Date,'') as nvarchar(11)) 
												+ '#' + 'Off Day :' + ISNULL(@Old_Weekoff_Day,'')
												+ '#' + 
												'New Value' + '#'+ 'Employee Name :' + ISNULL( @Old_Emp_Name,'') 
												+ '#' + 'Branch abc Name :' + ISNULL(@New_Branch_Name,'') 												
												+ '#' + 'Effective Date :' + cast(ISNULL(@For_Date,'') as nvarchar(11)) 
												+ '#' + 'Off Day :' + ISNULL(@Weekoff_Day,'')
								exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'Employee Weekoff',@Oldvalue,@Emp_ID,@User_Id,@IP_Address,1
								*/
				
			end	
	Else If @tran_type ='D'
		begin
			/* commneted binal beacuse not need
			declare @W_For_Date as datetime
			declare @W_Emp_Id as numeric
			select @W_For_Date = For_Date,@W_Emp_Id=Emp_ID from T0070_WEEKOFF_ADJ_APP where W_Tran_ID = @W_Tran_ID 
			if Not Exists(Select 1 from T0200_MONTHLY_SALARY where Emp_ID=@W_Emp_Id and Month_End_Date >= @For_Date )--Currnet Month Salary Employee Weekoff delete change by paras 16/07/2013
				Begin
				
								
								Select 
								@Old_Emp_Id = Emp_ID
								,@Old_For_Date = For_Date
								,@Old_Weekoff_Day = Weekoff_Day
								From T0070_WEEKOFF_ADJ_APP Where W_Tran_ID = @W_Tran_ID
								
								Set @Old_Emp_Name = (Select ISNULL(Alpha_Emp_Code,'') + ' - ' + ISNULL(Emp_Full_Name,'')   from T0060_EMP_MASTER_APP Where Emp_ID =  @Old_Emp_Id)
								Set @Old_Branch_Name = (select Branch_Name from V0080_Employee_Master where Cmp_ID = @Cmp_ID and Emp_ID = @Old_Emp_Id)
								
								set @OldValue = 'old Value' + '#'+ 'Employee Name :' + ISNULL( @Old_Emp_Name,'') 
													+ '#' + 'Branch abc Name :' + ISNULL(@Old_Branch_Name,'') 												
													+ '#' + 'Effective Date :' + cast(ISNULL(@Old_For_Date,'') as nvarchar(11)) 
													+ '#' + 'Off Day :' + ISNULL(@Old_Weekoff_Day,'') 												
														
								exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'Employee Weekoff',@Oldvalue,@Emp_ID,@User_Id,@IP_Address,1												
								
								
					delete  from T0070_WEEKOFF_ADJ_APP where W_Tran_ID = @W_Tran_ID
				End
				
				delete  from T0070_WEEKOFF_ADJ_APP where W_Tran_ID = @W_Tran_ID
			Else
				begin
					set @W_Tran_Id = 0
					return
				End
				*/
				delete  from T0070_WEEKOFF_ADJ_APP where W_Tran_ID = @W_Tran_ID 
		end	

	RETURN


/*For Shift Rotation*/ /* commented binal */
--If Exists(Select 1 From T0050_EMP_MONTHLY_SHIFT_ROTATION Where Emp_ID=@Emp_Id AND Effective_Date < @For_Date)
--	BEGIN
--		DECLARE @ROTATION_ID NUMERIC
--		DECLARE @CONSTRAINT VARCHAR(MAX)
--		SELECT TOP 1 @ROTATION_ID=ROTATION_ID FROM T0050_EMP_MONTHLY_SHIFT_ROTATION WHERE Emp_ID=@Emp_Id  AND Effective_Date < @For_Date
--		ORDER BY Effective_Date DESC

--		SET @CONSTRAINT = CAST(@EMP_ID AS VARCHAR(MAX))
--		EXEC P0050_ASSIGN_SHIFT_BY_ROTATION @Cmp_ID=@CMP_ID, @Effective_Date=@For_Date, @Constraint=@CONSTRAINT
--	END	
/*End of Code*/


