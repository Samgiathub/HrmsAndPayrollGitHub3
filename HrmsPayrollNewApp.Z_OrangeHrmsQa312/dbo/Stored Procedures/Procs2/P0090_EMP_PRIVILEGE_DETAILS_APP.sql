CREATE PROCEDURE [dbo].[P0090_EMP_PRIVILEGE_DETAILS_APP]
	@Emp_Tran_ID as numeric(18,0),
	@Trans_Id as numeric(18,0) output,
	@Privilege_ID AS numeric,
	@CMP_ID AS numeric(18,0),
	@Effect_Date as datetime,
	@Approved_Emp_ID numeric(18,0),
	@Rpt_Level numeric(5,0),
	@tran_type varchar(1) = 'I',
	@User_Id numeric(18,0) = 0,	
	@IP_Address varchar(30)= '' 
AS
	Declare @Approved_Date datetime
	Declare @Old_Emp_Tran_ID as numeric
	Declare @Old_Emp_Name as varchar(100)
	Declare @Old_Privilege_ID as numeric
	Declare @New_Privilage_Name as varchar(150)
	Declare @Old_Privilage_Name as varchar(150)
	Declare @Old_Effect_Date as datetime
	Declare @OldValue as varchar(max)
	Declare @Old_Approved_Emp_ID numeric(18,0)
	Declare @Old_Approved_Date datetime
	Declare @Old_Rpt_Level numeric(18,0)
						
	SET @Approved_Date=GETDATE()
	Set @Old_Emp_Tran_ID = 0
	Set @Old_Emp_Name = ''										
	Set @Old_Privilege_ID = 0										
	Set @Old_Privilage_Name = ''
	Set @New_Privilage_Name = ''
	Set @Old_Effect_Date  = null
	Set @OldValue = ''
	Set @Old_Approved_Emp_ID=0
	Set @Old_Approved_Date=null
	Set @Old_Rpt_Level =0 

	If @tran_type  = 'I'
		Begin	
			If Exists(Select Trans_ID 
					  From T0090_EMP_PRIVILEGE_DETAILS_APP  With(NOLOCK)
					  Where Cmp_ID = @Cmp_ID and Emp_Tran_ID = @Emp_Tran_ID  
							--and From_Date = @Effect_Date
					  
				    ) 
			begin
							
				Select @Old_Emp_Tran_ID =@Emp_Tran_ID,					   
					  @Old_Privilege_ID = Privilege_Id,
					  @Old_Effect_Date = From_Date,
					  @Old_Approved_Emp_ID=Approved_Emp_ID,
					  @Old_Approved_Date=Approved_Date,
					  @Old_Rpt_Level=Rpt_Level
				from T0090_EMP_PRIVILEGE_DETAILS_APP   With(NOLOCK)
				where  Emp_Tran_ID = @Emp_Tran_ID  
						and Cmp_Id = @Cmp_Id --and From_Date = @Effect_Date
										
				Set @Old_Emp_Name = (Select ISNULL(Alpha_Emp_Code,'') + ' - ' + ISNULL(Emp_Full_Name,'') from T0060_EMP_MASTER_APP   With(NOLOCK)
					where Emp_Tran_ID = @Emp_Tran_ID  
						and Cmp_Id = @Cmp_Id)										
				Set @Old_Privilage_Name = (select Privilege_Name from T0020_PRIVILEGE_MASTER   With(NOLOCK)
											where Cmp_Id = @CMP_ID And Privilege_ID = @Old_Privilege_ID)
				Set @New_Privilage_Name = (select Privilege_Name from T0020_PRIVILEGE_MASTER   With(NOLOCK)
											where Cmp_Id = @CMP_ID And Privilege_ID = @Privilege_ID)
										
				set @OldValue = 'old Value' + '#'+ 'Employee Name :' + ISNULL( @Old_Emp_Name,'') 
											+ '#' + 'Assigned Privilege :' + ISNULL(@Old_Privilage_Name,'') 																						
											+ '#' + 'Effect Date :' + cast(ISNULL(@Old_Effect_Date,'') as nvarchar(11)) 
											+ '#'+ 'Emp_Tran_ID :' + cast(ISNULL(@Old_Emp_Tran_ID,0) as nvarchar(100))
											+ '#'+ 'Approved_Emp_ID :' + cast(ISNULL( @Old_Approved_Emp_ID,0) as nvarchar(100))
											+ '#'+ 'Approved_Date :' + cast(ISNULL(@Old_Approved_Date,'') as nvarchar(11)) 
											+ '#'+ 'Rpt_Level :' + cast(ISNULL( @Old_Rpt_Level,0) as nvarchar(100))
											+ '#' +
											+ 'New Value' + '#'+ 'Employee Name :' + ISNULL( @Old_Emp_Name,'') 
											+ '#' + 'Assigned Privilege :' + ISNULL(@New_Privilage_Name,'') 																						
											+ '#' + 'Effect Date :' + cast(ISNULL(@Effect_Date,'') as nvarchar(11)) 
											+ '#'+ 'Emp_Tran_ID :' + cast(ISNULL(@Emp_Tran_ID,0) as nvarchar(100))
											+ '#'+ 'Approved_Emp_ID :' + cast(ISNULL( @Approved_Emp_ID,0)  as nvarchar(100))
											+ '#'+ 'Approved_Date :' + cast(ISNULL(@Approved_Date,'') as nvarchar(11)) 
											+ '#'+ 'Rpt_Level :' + cast(ISNULL(@Rpt_Level,0) as nvarchar(100))
				exec P9999_Audit_Trail @Cmp_ID,'U','Employee Privileges App make checker',@Oldvalue,@Approved_Emp_ID,@User_Id,@IP_Address,1
										
										-- Added for audit trail by Ali on 10102013 -- End
										
				UPDATE   T0090_EMP_PRIVILEGE_DETAILS_APP
				SET     Privilege_Id = @Privilege_ID
				where Emp_Tran_ID = @Emp_Tran_ID  
					 and Cmp_Id = @Cmp_Id 
					 --and From_Date = @Effect_Date
							
			end
			--else If Exists(Select Trans_ID From T0090_EMP_PRIVILEGE_DETAILS_APP  
			--				Where Cmp_ID = @Cmp_ID and Emp_Tran_ID = @Emp_Tran_ID  
			--				and From_Date > @Effect_Date) 
			--		begin
					
			--			set @Trans_Id = 0
														
			--		end
			else
				begin
						
						select @Trans_Id = isnull(Trans_Id,0) 
						From T0090_EMP_PRIVILEGE_DETAILS_APP    With(NOLOCK)
						Where Cmp_ID = @Cmp_ID and Emp_Tran_ID = @Emp_Tran_ID 
						--declare @tmpEffDate datetime
						--if @Trans_Id = 0
						--	begin
								
						--		select @tmpEffDate = em.Date_Of_Join  from T0080_EMP_MASTER em inner join
						--		T0011_LOGIN LG on lg.Emp_ID = em.Emp_ID
						--		where LG.Login_ID = @Login_Id
								
						--		if @tmpEffDate > @Effect_Date
						--			begin
						--				set @Effect_Date = @tmpEffDate
						--			end
								
						--	end
					
						select @Trans_Id = Isnull(max(Trans_Id),0) + 1 	From T0090_EMP_PRIVILEGE_DETAILS_APP   With(NOLOCK)
												
						INSERT INTO T0090_EMP_PRIVILEGE_DETAILS_APP
								 (Emp_Tran_ID,Trans_Id, Cmp_Id,Privilege_Id,From_Date,Approved_Emp_ID,Approved_Date,Rpt_Level)
						VALUES     (@Emp_Tran_ID,@Trans_Id,@CMP_ID,@Privilege_ID,@Effect_Date,@Approved_Emp_ID,@Approved_Date,@Rpt_Level)
						
						Set @Old_Emp_Name = (Select ISNULL(Alpha_Emp_Code,'') + ' - ' + ISNULL(Emp_Full_Name,'') from T0060_EMP_MASTER_APP   With(NOLOCK)
												where Emp_Tran_ID = @Emp_Tran_ID  
											and Cmp_Id = @Cmp_Id)										
						Set @Old_Privilage_Name = (select Privilege_Name from T0020_PRIVILEGE_MASTER   With(NOLOCK)
											where Cmp_Id = @CMP_ID And Privilege_ID = @Privilege_ID)
								
						set @OldValue = 'New Value' + '#'+ 'Employee Name :' + ISNULL( @Old_Emp_Name,'') 
												+ '#' + 'Assigned Privilege :' + ISNULL(@Old_Privilage_Name,'') 																						
												+ '#' + 'Effect Date :' + cast(ISNULL(@Effect_Date,'') as nvarchar(11))
												+ '#'+ 'Emp_Tran_ID :' +cast( ISNULL(@Emp_Tran_ID,0) as nvarchar(100))
												+ '#'+ 'Approved_Emp_ID :' + cast(ISNULL( @Approved_Emp_ID,0) as nvarchar(100))
												+ '#'+ 'Approved_Date :' + cast(ISNULL(@Approved_Date,'') as nvarchar(11)) 
												+ '#'+ 'Rpt_Level :' + cast(ISNULL(@Rpt_Level,0)as nvarchar(100))
						exec P9999_Audit_Trail @Cmp_ID,@tran_type,'Employee Privileges App make checker',@Oldvalue,@Approved_Emp_ID,@User_Id,@IP_Address,1
									
					end				
		End
	Else if @Tran_Type = 'D'
		begin
				select @Trans_Id
					
				Select @Old_Emp_Tran_ID =@Emp_Tran_ID,					   
					  @Old_Privilege_ID = Privilege_Id,
					  @Old_Effect_Date = From_Date,
					  @Old_Approved_Emp_ID=Approved_Emp_ID,
					  @Old_Approved_Date=Approved_Date,
					  @Old_Rpt_Level=Rpt_Level
				from T0090_EMP_PRIVILEGE_DETAILS_APP   With(NOLOCK)
				where   Trans_ID = @Trans_Id
										
				Set @Old_Emp_Name = (Select ISNULL(Alpha_Emp_Code,'') + ' - ' + ISNULL(Emp_Full_Name,'') from T0060_EMP_MASTER_APP   With(NOLOCK)
									 where Emp_Tran_ID = @Emp_Tran_ID  
											and Cmp_Id = @Cmp_Id)										
				Set @Old_Privilage_Name = (select Privilege_Name from T0020_PRIVILEGE_MASTER   With(NOLOCK)
											where Cmp_Id = @CMP_ID And Privilege_ID = @Privilege_ID)
						
				set @OldValue = 'old Value' + '#'+ 'Employee Name :' + ISNULL( @Old_Emp_Name,'') 
												+ '#' + 'Assigned Privilege :' + ISNULL(@Old_Privilage_Name,'') 																						
												+ '#' + 'Effect Date :' + cast(ISNULL(@Old_Effect_Date,'') as nvarchar(11)) 
												+ '#'+ 'Emp_Tran_ID :' + cast(ISNULL(@Old_Emp_Tran_ID,0) as nvarchar(100))
												+ '#'+ 'Approved_Emp_ID :' +cast( ISNULL( @Old_Approved_Emp_ID,0) as nvarchar(100))
												+ '#'+ 'Approved_Date :' + cast(ISNULL(@Old_Approved_Date,'') as nvarchar(11)) 
												+ '#'+ 'Rpt_Level :' + cast(ISNULL( @Old_Rpt_Level,0)as nvarchar(100))

				exec P9999_Audit_Trail @Cmp_ID,@tran_type,'Employee Privileges App make checker',@Oldvalue,@Approved_Emp_ID,@User_Id,@IP_Address,1
										
				Delete From T0090_EMP_PRIVILEGE_DETAILS_APP Where Trans_ID = @Trans_Id
		end

	RETURN