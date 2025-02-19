
--declare @p1 int set @p1=20393 exec P0095_INCREMENT_DELETE @Increment_ID=@p1 output,@Emp_ID=0,@Cmp_ID=119 select @p1	
---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0095_INCREMENT_DELETE]
	 @Increment_ID	numeric(18, 0) output
	,@Emp_ID		numeric(18, 0)
	,@Cmp_ID		numeric(18, 0)
	,@User_Id numeric(18,0) = 0   --Added By Mukti 01072016
	,@IP_Address varchar(30)= '' --Added By Mukti 01072016
	,@Flag			Varchar(50) = '' --Ankit 24062016
	AS 
	SET NOCOUNT ON 
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ARITHABORT ON
	
		Begin 
		
			Declare @Max_Increment_ID	numeric 
			Declare @Increment_eff_Date Datetime
			Declare @Max_Increment_eff_Date Datetime --Ankit 03092014
			
			SELECT @EMP_ID =EMP_ID ,@Increment_eff_Date = Increment_Effective_Date  FROM T0095_INCREMENT  WITH (NOLOCK)  WHERE Increment_ID	= @Increment_ID 

			--Hardik 11/09/2018 for AIA, If Salary has been generated with Same Increment ID or Greater Increment Id, then It should not update or delete
			IF EXISTS(Select 1 From T0200_MONTHLY_SALARY WITH (NOLOCK) Where Emp_ID = @Emp_Id And @Increment_eff_Date < Month_End_Date) And @Increment_ID > 0
				IF EXISTS(Select 1 From T0200_MONTHLY_SALARY WITH (NOLOCK) Where Emp_ID =@Emp_Id And Increment_ID >= @Increment_Id) And @Increment_ID > 0
					BEGIN
						RAISERROR('@@Cannot Delete, Salary Exists@@',16,2)
						RETURN
					END

			IF EXISTS(Select 1 From T0095_INCREMENT WITH (NOLOCK) Where Emp_ID =@Emp_Id And Increment_ID > @Increment_Id) And @Increment_ID > 0
				BEGIN
					RAISERROR('@@Cannot Delete, Next Increment Exists@@',16,2)
					RETURN
				END

			
			IF @Flag <> 'Increment Application' AND EXISTS ( SELECT 1 FROM T0095_INCREMENT WITH (NOLOCK) WHERE Emp_ID = @EMP_ID AND Increment_ID = @Increment_ID AND ISNULL(Increment_App_ID ,0) <> 0 )
				BEGIN
					RAISERROR('@@ Employee Increment Approval Exists, First Delete it @@',16,2)
					RETURN -1
				END
				
			--Added By Mukti 01-07-2016(Start)		
			declare @OldValue as  varchar(max) 
			Declare @String as varchar(max)
			declare @Tran_Type Char(1)
			set @String =''
			set @OldValue = ''	
			set @Tran_Type = 'D'						
			exec P9999_Audit_get @table = 'T0095_INCREMENT' ,@key_column='Increment_ID',@key_Values=@Increment_ID ,@String=@String output
			set @OldValue = @OldValue + 'Old Value' + '#' + cast(@String as varchar(max))
			--Added By Mukti 01-07-2016(End)
			
			SELECT @EMP_ID =EMP_ID ,@Increment_eff_Date = Increment_Effective_Date  FROM T0095_INCREMENT  WITH (NOLOCK)   WHERE Increment_ID	= @Increment_ID 
			
			if not exists(select Emp_ID from T0095_INCREMENT  WITH (NOLOCK)  WHERE 	Increment_ID	= @Increment_ID AND isnull(Is_Master_Rec,0)=1 )
				BEGIN
					 if  exists( select Emp_ID from T0095_INCREMENT  WITH (NOLOCK)  WHERE 	Emp_ID =@emp_ID and Increment_ID	<> @Increment_ID )
							Begin
							
							--if not exists(select Emp_ID from T0095_INCREMENT    WHERE 	Emp_ID =@emp_ID and Increment_ID <> @Increment_ID and Increment_Effective_Date in (select max(Increment_Effective_Date) from T0095_INCREMENT where Emp_ID =@emp_ID  ) )
							/*
							IF not exists(select Emp_ID from T0095_INCREMENT WHERE 	Emp_ID =@emp_ID and Increment_ID <> @Increment_ID and Increment_ID in 
											(select max(Increment_ID) from T0095_INCREMENT TI inner join
												(Select Max(Increment_Effective_Date) as Increment_Effective_Date from T0095_Increment 
													Where Increment_effective_Date <= @Increment_eff_Date --GetDate() 
													And Cmp_ID=@Cmp_Id And Emp_ID = @Emp_Id ) new_inc
												on Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date  where Emp_ID =@emp_ID  ) ) 
							*/
							If NOT EXISTS(SELECT 1 from T0095_INCREMENT WITH (NOLOCK) WHERE Emp_ID =@Emp_ID AND Increment_ID > @Increment_ID)							
							Begin
								
								Declare @Appr_int_ID numeric(18,0)
								Declare @Number_App numeric(18,0)
								select @Appr_int_ID = isnull(Appr_int_ID,0) from t0090_hrms_appraisal_initiation_detail WITH (NOLOCK) where Increment_ID=@Increment_ID
														
								
								Update t0090_hrms_appraisal_initiation_detail set Increment_ID = null,Is_Accept=2
								where Emp_ID=@Emp_ID And  Increment_ID=@Increment_ID
								
								if isnull(@Appr_int_ID,0) <> 0
									Begin
										select @Number_App = isnull(count(Emp_ID),0) from t0090_hrms_appraisal_initiation_detail WITH (NOLOCK) where Appr_int_ID=@Appr_int_ID and Increment_ID is not null
										if isnull(@Number_App,0) = 0 
											Update t0090_hrms_appraisal_initiation set Status=0 where Appr_int_ID=@Appr_int_ID
									End
								
								
							
								Update T0080_EMP_MASTER SET INCREMENT_ID = NULL WHERE EMP_ID =@EMP_ID  
								Delete From T0100_Emp_Manager_History where Increment_ID = @Increment_ID and cmp_ID = @Cmp_ID -- Added by Falak on 25-APR-2011
								Delete	From T0100_EMP_EARN_DEDUCTION	Where Increment_ID	= @Increment_ID and Cmp_ID=@Cmp_ID 
								Delete	From T0095_INCREMENT			Where Increment_ID	= @Increment_ID and Cmp_ID=@Cmp_ID  
							
							--- Update latest record in Employee Master 
								--Select @Max_Increment_ID = Increment_ID From T0095_Increment I inner join
								--(select Max(Increment_Effective_Date)Increment_Effective_Date ,Emp_ID From T0095_Increment where Emp_ID=@Emp_ID group by emp_ID)Q on
								--i.Emp_ID= q.Emp_ID  and i.Increment_Effective_Date =q.Increment_Effective_Date
								
								Select @Max_Increment_ID = I.Increment_ID , @Max_Increment_eff_Date = Increment_Effective_Date 
								From T0095_Increment I WITH (NOLOCK) inner join
								(select Max(Increment_ID)Increment_ID ,Emp_ID From T0095_Increment WITH (NOLOCK) where Emp_ID=@Emp_ID group by emp_ID)Q on
								i.Emp_ID= q.Emp_ID  and i.Increment_ID =q.Increment_ID
								
								Update T0080_Emp_Master 
								set Increment_Id =@Max_Increment_ID
								Where Emp_ID =@Emp_ID 
							----------------------------------------------
								-- done by zalak 
								--for histroy manage for manager & update latest manager in employee master
								--delete  emp_superior from t0100_emp_manager_history where Increment_Id =@Increment_ID
								--Commented by Falak on 03-MAY-2011 
								
								-------Update Reporing Manger ID on Emp_Master Table	--Ankit 01052015
								
								DELETE  FROM T0090_EMP_REPORTING_DETAIL WHERE Emp_Id = @Emp_Id And Effect_Date = @Increment_eff_Date
								
								DECLARE @RE_Emp_ID NUMERIC
								SET @RE_Emp_ID = 0
								
								SELECT @RE_Emp_ID = R_Emp_ID
								From T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK) INNER JOIN 
									(SELECT MAX(Effect_Date) as Effect_Date, Emp_ID from T0090_EMP_REPORTING_DETAIL WITH (NOLOCK)
									 WHERE Effect_Date<=@Increment_eff_Date And Emp_ID = @Emp_ID
									 GROUP BY emp_ID) RQry on  ERD.Emp_ID = RQry.Emp_ID and ERD.Effect_Date = RQry.Effect_Date
								WHERE ERD.Emp_ID = @Emp_ID
								
								IF @RE_Emp_ID > 0
									BEGIN
										UPDATE T0080_EMP_MASTER SET Emp_Superior = @RE_Emp_ID WHERE Emp_ID = @Emp_ID
									END
								Else --Condition Added by Sumit to pass null when no employee in Reporttin Detail 15042015
									Begin
										UPDATE T0080_EMP_MASTER SET Emp_Superior = null WHERE Emp_ID = @Emp_ID
									End	
									
								-------Update Reporing Manger ID on Emp_Master Table	--Ankit 01052015
					
								
								--Update T0080_Emp_Master 
								--set emp_superior = (select emp_superior from t0100_emp_manager_history where Increment_Id =@Max_Increment_ID)
								--Where Emp_ID =@Emp_ID 
								end
							else
							begin
								if 'Transfer'=(select top 1 Increment_Type from T0095_INCREMENT  WITH (NOLOCK)  WHERE 	Emp_ID =@emp_ID and Increment_ID <> @Increment_ID  --and Increment_Effective_Date in (select max(Increment_Effective_Date) from T0095_INCREMENT where Emp_ID =@emp_ID  ) )
												and Increment_ID in 
													(select max(Increment_ID) from T0095_INCREMENT TI WITH (NOLOCK) inner join
														(Select Max(Increment_Effective_Date) as Increment_Effective_Date from T0095_Increment WITH (NOLOCK)
															Where Increment_effective_Date <= GetDate() And Cmp_ID=@Cmp_Id And Emp_ID = @Emp_Id ) new_inc
														on Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date  where Emp_ID =@emp_ID  ) )
								begin
									select Emp_ID from T0095_INCREMENT  WITH (NOLOCK)  WHERE 	Emp_ID =@emp_ID and Increment_ID	<> @Increment_ID and Increment_ID in 
										(select max(Increment_ID) from T0095_INCREMENT TI WITH (NOLOCK) inner join
											(Select Max(Increment_Effective_Date) as Increment_Effective_Date from T0095_Increment WITH (NOLOCK)
												Where Increment_effective_Date <= GetDate() And Cmp_ID=@Cmp_Id And Emp_ID = @Emp_Id ) new_inc
											on Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date  where Emp_ID =@emp_ID  )
								
									Raiserror('@@Transfer entry exist. First Delete that entry@@',16,2)
									return -1
								end
								else
								begin
									
								
									/*
										If exists(select Emp_ID from T0095_INCREMENT    WHERE 	Emp_ID =@emp_ID and Increment_ID <> @Increment_ID and Increment_ID in 
												(select max(Increment_ID) from T0095_INCREMENT TI inner join
													(Select Max(Increment_Effective_Date) as Increment_Effective_Date from T0095_Increment 
														Where Increment_effective_Date <= @Increment_eff_Date --GetDate() 
														And Cmp_ID=@Cmp_Id And Emp_ID = @Emp_Id ) new_inc
													on Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date  where Emp_ID =@emp_ID  ) )
									*/
									
									If EXISTS(SELECT 1 from T0095_INCREMENT WITH (NOLOCK) WHERE Emp_ID =@Emp_ID AND Increment_ID > @Increment_ID)
										Raiserror('@@Increment entry exist. First Delete that entry@@',16,2)
										return -1
								end
							end
							
							End
						else
							Begin
								select Emp_ID from T0095_INCREMENT  WITH (NOLOCK)  WHERE 	Emp_ID =@emp_ID and Increment_ID	<> @Increment_ID 
								Raiserror('@@No More Record Found, U Cant Delete.@@',16,2)
								return -1
							end
				END
			else 
				begin
					Raiserror('@@Master Record Found, U Cant Delete.@@',16,2)
					return -1
				end
		END		
	exec P9999_Audit_Trail @Cmp_ID,@tran_type,'Employee Increment',@OldValue,@Emp_ID,@User_Id,@IP_Address,1 --added By Mukti 01072016
	RETURN




