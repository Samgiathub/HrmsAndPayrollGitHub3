

---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0095_EMP_CMP_TRANSFER_DELETE]

	 @Tran_Id as numeric
	,@Old_Cmp_Id as numeric
	,@Old_Emp_Id as numeric
	,@New_Cmp_Id as numeric
	,@New_Emp_Id as numeric

AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
			
			--''Check Salary Exist In New company--''
			If Exists (Select Emp_ID FROM T0200_MONTHLY_SALARY WITH (NOLOCK) WHERE Emp_ID = @New_Emp_Id and Cmp_ID = @New_Cmp_Id)	
				Begin
					Raiserror('Employee salary exists In new company',16,2)
					Return -1
				End
			--''Check Salary Exist In New company--''
			
			
			
			--''Leave Detail''--
			
			DELETE FROM T0140_LEAVE_TRANSACTION where Emp_ID = @New_Emp_Id And cmp_Id=@New_Cmp_Id--Adv_Tran_ID = @Adv_Tran_ID
			
			If Exists (Select Tran_Id FROM T0100_EMP_COMPANY_LEAVE_TRANSFER WITH (NOLOCK) WHERE Tran_Id=@Tran_Id)	
				Begin 
					--Update T0140_LEAVE_TRANSACTION 
					--Set    Leave_Closing = Leave_Posting ,
					--	   Leave_Posting = 0	
					--Where  Emp_ID=@Old_Emp_Id AND Cmp_ID = @Old_Cmp_Id AND Leave_Closing = 0
					--	   AND For_date = (SELECT MAX(for_date) FROM T0140_LEAVE_TRANSACTION 
					--									WHERE emp_id = @Old_Emp_Id AND Cmp_ID = @Old_Cmp_Id	And Leave_Posting Is not Null)		
					Declare @old_balance_L numeric(18,2)
					Declare @CurTeam_Emp_Id numeric 	 
					
					Set @CurTeam_Emp_Id = 0	
					Declare CusrUpdateOld_Leave cursor for	                 
						select Leave_ID From T0100_EMP_COMPANY_LEAVE_TRANSFER WITH (NOLOCK) Where New_Emp_Id = @New_Emp_Id And New_Cmp_Id = @New_Cmp_Id And Tran_Id=@Tran_Id
						
						Open CusrUpdateOld_Leave
							Fetch next from CusrUpdateOld_Leave into @CurTeam_Emp_Id
							While @@fetch_status = 0                    
								Begin 
									 set @old_balance_L = 0
									   
									Select @old_balance_L = Old_Balance
									From T0100_EMP_COMPANY_LEAVE_TRANSFER WITH (NOLOCK) Where Leave_Id = @CurTeam_Emp_Id
										
									Update T0140_LEAVE_TRANSACTION 
									Set    Leave_Closing = @old_balance_L ,
										   Leave_Posting = 0	
									Where  Emp_ID=@Old_Emp_Id	And Leave_ID = @CurTeam_Emp_Id
										
									fetch next from CusrUpdateOld_Leave into @CurTeam_Emp_Id	
								End
						Close CusrUpdateOld_Leave                    
					Deallocate CusrUpdateOld_Leave
				End
			
			DELETE FROM T0100_EMP_COMPANY_LEAVE_TRANSFER WHERE Tran_Id=@Tran_Id
			--''Leave Detail''--
			
			--''Advace Detail''--
			--DELETE FROM T0140_ADVANCE_TRANSACTION where Emp_ID = @New_Emp_Id And cmp_Id=@New_Cmp_Id--Adv_Tran_ID = @Adv_Tran_ID
			DELETE FROM T0100_ADVANCE_PAYMENT where Emp_ID = @New_Emp_Id And cmp_Id=@New_Cmp_Id  --added jimit 02122015
			
			Declare @Ad_Old_Balance Numeric
			Select @Ad_Old_Balance = Old_Balance FROM T0100_EMP_COMPANY_ADVANCE_TRANSFER WITH (NOLOCK) WHERE Tran_Id=@Tran_Id --and Emp_Id = @New_Emp_Id
			
			If @Ad_Old_Balance is Null
				set @Ad_Old_Balance = 0
			
			--If Exists (Select Tran_Id FROM T0100_EMP_COMPANY_ADVANCE_TRANSFER WHERE Tran_Id=@Tran_Id)
			--	Begin
			--		Update T0140_ADVANCE_TRANSACTION 
			--		Set    Adv_Closing = @Ad_Old_Balance
			--		Where  Emp_ID=@Old_Emp_Id and Cmp_ID = @Old_Cmp_Id
			--			   AND For_date = (SELECT MAX(for_date) FROM T0140_ADVANCE_TRANSACTION 
			--											WHERE emp_id = @Old_Emp_Id AND Cmp_ID = @Old_Cmp_Id	)		
			--	End
			If Exists (Select Tran_Id FROM T0100_EMP_COMPANY_ADVANCE_TRANSFER WITH (NOLOCK) WHERE Tran_Id=@Tran_Id)
				Begin
				
					Update T0100_ADVANCE_PAYMENT 
					Set    Adv_Amount = @Ad_Old_Balance
					Where  Emp_ID=@Old_Emp_Id and Cmp_ID = @Old_Cmp_Id
						   AND For_date = (SELECT MAX(for_date) FROM T0100_ADVANCE_PAYMENT WITH (NOLOCK)
														WHERE emp_id = @Old_Emp_Id AND Cmp_ID = @Old_Cmp_Id	)	
																		
				End
			
			
			DELETE FROM T0100_EMP_COMPANY_ADVANCE_TRANSFER WHERE Tran_Id=@Tran_Id
			--''Advace Detail''--
		
			--''Loan Detail''--
			DELETE FROM T0120_LOAN_APPROVAL where Emp_Id = @New_Emp_Id and Cmp_ID = @New_Cmp_Id
			DELETE FROM T0140_LOAN_TRANSACTION where Emp_Id = @New_Emp_Id and Cmp_ID = @New_Cmp_Id
			
			Declare @Old_Balance Numeric
			Select @Old_Balance = Old_Balance FROM T0100_EMP_COMPANY_LOAN_TRANSFER WITH (NOLOCK) WHERE Tran_Id=@Tran_Id and New_Emp_Id = @New_Emp_Id
			
			If @Old_Balance is null
				set @Old_Balance = 0
			
			IF Exists (Select Tran_Id FROM T0100_EMP_COMPANY_LOAN_TRANSFER WITH (NOLOCK) WHERE Tran_Id=@Tran_Id and New_Emp_Id = @New_Emp_Id)
				Begin
					Update T0140_LOAN_TRANSACTION 
					Set    Loan_Closing = @Old_Balance
					Where  Emp_ID=@Old_Emp_Id and Cmp_ID = @Old_Cmp_Id
						   AND For_date = (SELECT MAX(for_date) FROM T0140_LOAN_TRANSACTION WITH (NOLOCK)
														WHERE emp_id = @Old_Emp_Id AND Cmp_ID = @Old_Cmp_Id	)	
				End
			
			
			DELETE FROM T0100_EMP_COMPANY_LOAN_TRANSFER WHERE Tran_Id=@Tran_Id and New_Emp_Id = @New_Emp_Id
			--''Loan Detail''--
		 
	
		    --''Bond Detail''--
			DELETE FROM T0120_BOND_APPROVAL where Emp_Id = @New_Emp_Id and Cmp_ID = @New_Cmp_Id
			DELETE FROM T0140_BOND_TRANSACTION where Emp_Id = @New_Emp_Id and Cmp_ID = @New_Cmp_Id
			
			Declare @Old_Bond_Balance Numeric
			Select @Old_Bond_Balance = Old_Balance FROM T0100_EMP_COMPANY_BOND_TRANSFER WITH (NOLOCK) WHERE Tran_Id=@Tran_Id and New_Emp_Id = @New_Emp_Id
			
			If @Old_Bond_Balance is null
				set @Old_Bond_Balance = 0
			
			IF Exists (Select Tran_Id FROM T0100_EMP_COMPANY_BOND_TRANSFER WITH (NOLOCK) WHERE Tran_Id=@Tran_Id and New_Emp_Id = @New_Emp_Id)
				Begin
					Update T0140_BOND_TRANSACTION 
					Set    Bond_Closing = @Old_Bond_Balance
					Where  Emp_ID=@Old_Emp_Id and Cmp_ID = @Old_Cmp_Id
						   AND For_date = (SELECT MAX(for_date) FROM T0140_BOND_TRANSACTION WITH (NOLOCK)
														WHERE emp_id = @Old_Emp_Id AND Cmp_ID = @Old_Cmp_Id	)	
				End
			
			
			DELETE FROM T0100_EMP_COMPANY_BOND_TRANSFER WHERE Tran_Id=@Tran_Id and New_Emp_Id = @New_Emp_Id
			--''Bond Detail''--
		 
		 
		 
			--''Salary Detail''--
			DELETE FROM T0100_EMP_COMPANY_TRANSFER_SALARY_DETAIL WHERE Tran_Id=@Tran_Id and New_Emp_Id = @New_Emp_Id
			
			DELETE FROM T0100_EMP_COMPANY_TRANSFER_EARN_DEDUCTION WHERE Tran_Id=@Tran_Id and New_Emp_Id = @New_Emp_Id
			--''Salary Detail''--
			
			--''New Company Emp Delete and Old Company Emp Left Delete''--
			Declare @Left_ID Numeric
			
			DECLARE @Enroll_No NUMERIC  
			If exists (select 1 From T0100_LEFT_EMP WITH (NOLOCK) Where Emp_ID=@Old_Emp_Id And Cmp_ID=@Old_Cmp_Id And Left_Reason = 'Default Company Transfer')
				Begin
					select @Left_ID = Left_ID From T0100_LEFT_EMP WITH (NOLOCK) Where Emp_ID=@Old_Emp_Id And Cmp_ID=@Old_Cmp_Id And Left_Reason = 'Default Company Transfer'
					
					Delete  from T0100_LEFT_EMP where Left_ID = @Left_ID 
					--added jimit 04112015
					SELECT @Enroll_No = Enroll_No FROM 
						T0080_EMP_MASTER WITH (NOLOCK) WHERE Cmp_ID = @New_Cmp_Id and Emp_ID = @New_Emp_Id
					--ended
					
					UPDATE T0080_EMP_MASTER 
					SET EMP_LEFT  = 'N' , EMP_LEFT_DATE = null
						,Enroll_No = @Enroll_No									--added jimit 04112015
					WHERE EMP_ID = @Old_Emp_Id And Cmp_ID = @Old_Cmp_Id
				End
			
			--added jimit 29122015
					DECLARE @Desig_Id AS NUMERIC
					--added by jimit 12012017			
					DECLARE @New_R_Emp_id AS NUMERIC
					DECLARE @R_Cmp_Id as numeric
					--ended				
					--DECLARE @Increment_Date AS DATETIME
					
					
					--Select @Increment_Date = Effective_Date from T0095_EMP_COMPANY_TRANSFER	WHERE Tran_Id = @tran_Id	
					
						
						--Update T0090_EMP_REPORTING_DETAIL 
						--set  R_Emp_ID = @Old_Emp_Id ,Effect_Date = @Increment_Date
						--where Emp_ID in (select Emp_ID from T0090_EMP_REPORTING_DETAIL_REPLACE_HISTORY where  Old_R_Emp_id = @Old_Emp_Id)
						--	And Effect_Date = @Increment_Date
							
					
					select top 1 @New_R_Emp_id = New_R_Emp_id
					from T0090_EMP_REPORTING_DETAIL_REPLACE_HISTORY WITH (NOLOCK)
					where Old_R_emp_Id = @Old_Emp_Id 
					order by Row_id DESC
					
					delete from T0090_EMP_REPORTING_DETAIL_REPLACE_HISTORY where New_R_Emp_id = @New_R_Emp_id
					
					
					SELECT @Desig_Id = Old_Desig_Id from T0095_EMP_COMPANY_TRANSFER WITH (NOLOCK) WHERE Tran_Id = @Tran_Id
					
					UPDATE T0050_Scheme_Detail	
					SET		App_Emp_ID = @Old_Emp_Id ,R_Desg_Id = @Desig_ID
							,R_Cmp_Id = @Old_Cmp_Id
					WHERE Is_RM = 0 AND 
						  App_Emp_ID IN ( SELECT New_App_Emp_ID From T0051_Scheme_Detail_History WITH (NOLOCK) WHERE Old_App_Emp_ID = @Old_Emp_Id)

					Update T0051_Scheme_Detail_History
					SET New_App_Emp_ID = @Old_Emp_Id , System_date = GETDATE(),Cmp_Id = @Old_Cmp_Id
					WHERE New_App_Emp_ID IN ( SELECT New_App_Emp_ID From T0051_Scheme_Detail_History WITH (NOLOCK) WHERE Old_App_Emp_ID = @Old_Emp_Id)	

		
			---ended--------

			
			
			Update dbo.T0080_EMP_MASTER  Set Increment_ID = Null Where Emp_ID = @New_Emp_Id And cmp_Id=@New_Cmp_Id
			Delete From T0095_EMP_SCHEME			Where		Emp_ID	= @New_Emp_Id And cmp_Id=@New_Cmp_Id
			Delete From T0095_EMP_COMPANY_TRANSFER			Where		New_Emp_Id	= @New_Emp_Id-- And Tran_Id=@Tran_Id --Added by Hardik 02/12/2013 			
			Delete From T0090_EMP_CHILDRAN_DETAIL			Where		Emp_ID	= @New_Emp_Id And cmp_Id=@New_Cmp_Id
			Delete From T0090_EMP_CONTRACT_DETAIL			Where		Emp_ID	= @New_Emp_Id And cmp_Id=@New_Cmp_Id
			Delete From T0090_EMP_DEPENDANT_DETAIL			Where		Emp_ID	= @New_Emp_Id And cmp_Id=@New_Cmp_Id
			Delete From T0090_EMP_DOC_DETAIL				Where		Emp_ID  = @New_Emp_Id And cmp_Id=@New_Cmp_Id
			Delete From T0090_EMP_EMERGENCY_CONTACT_DETAIL	Where		Emp_ID  = @New_Emp_Id And cmp_Id=@New_Cmp_Id
			Delete From T0090_EMP_EXPERIENCE_DETAIL			Where		Emp_ID  = @New_Emp_Id And cmp_Id=@New_Cmp_Id
			Delete From T0090_EMP_IMMIGRATION_DETAIL		Where		Emp_ID  = @New_Emp_Id And cmp_Id=@New_Cmp_Id
			Delete From T0090_EMP_LANGUAGE_DETAIL			Where		Emp_ID  = @New_Emp_Id And cmp_Id=@New_Cmp_Id
			Delete From T0090_EMP_LICENSE_DETAIL			Where		Emp_ID  = @New_Emp_Id And cmp_Id=@New_Cmp_Id
			Delete From T0090_EMP_QUALIFICATION_DETAIL		Where		Emp_ID	= @New_Emp_Id And cmp_Id=@New_Cmp_Id
			--Delete From T0090_EMP_REPORTING_DETAIL			Where		Emp_ID	= @New_Emp_Id And cmp_Id=@New_Cmp_Id
			Delete From T0090_EMP_REPORTING_DETAIL			Where		R_Emp_ID = @New_R_Emp_id And cmp_Id=@New_Cmp_Id
			Delete From T0090_EMP_SKILL_DETAIL				Where		Emp_ID	= @New_Emp_Id And cmp_Id=@New_Cmp_Id			
			Delete from T0090_EMP_INSURANCE_DETAIL			Where		Emp_ID	= @New_Emp_Id And cmp_Id=@New_Cmp_Id	--Ankit 08022014
			Delete from T0090_EMP_ASSET_DETAIL				Where		Emp_ID	= @New_Emp_Id And cmp_Id=@New_Cmp_Id	--Ankit 08022014
			DELETE FROM T0110_EMP_LEFT_JOIN_TRAN			WHERE		EMP_ID	= @New_Emp_Id And cmp_Id=@New_Cmp_Id
			DELETE FROM T0100_EMP_EARN_DEDUCTION			WHERE		EMP_ID	= @New_Emp_Id And cmp_Id=@New_Cmp_Id
			DELETE from T0100_Emp_Manager_History			where		Emp_id  = @New_Emp_Id and Cmp_Id=@New_Cmp_Id--Added By Falak on 19-APR-2011
			DELETE FROM T0095_INCREMENT						WHERE		EMP_ID  = @New_Emp_Id And cmp_Id=@New_Cmp_Id
			DELETE FROM T0100_WEEKOFF_ADJ					WHERE		EMP_ID  = @New_Emp_Id And cmp_Id=@New_Cmp_Id
			DELETE FROM T0100_EMP_SHIFT_DETAIL				WHERE		EMP_ID  = @New_Emp_Id And cmp_Id=@New_Cmp_Id
			DELETE FROM T0140_ADVANCE_TRANSACTION			WHERE		EMP_ID  = @New_Emp_Id And cmp_Id=@New_Cmp_Id
			DELETE FROM T0100_ADVANCE_PAYMENT				WHERE		EMP_ID  = @New_Emp_Id And cmp_Id=@New_Cmp_Id --added jimit 02122015
			DELETE FROM T0140_LOAN_TRANSACTION			    WHERE		EMP_ID  = @New_Emp_Id And cmp_Id=@New_Cmp_Id
			DELETE FROM T0140_CLAIM_TRANSACTION			    WHERE		EMP_ID  = @New_Emp_Id And cmp_Id=@New_Cmp_Id
			DELETE FROM T0140_LEAVE_TRANSACTION			    WHERE		EMP_ID  = @New_Emp_Id And cmp_Id=@New_Cmp_Id	
			DELETE FROM T0190_MONTHLY_AD_DETAIL_IMPORT	    WHERE		EMP_ID  = @New_Emp_Id And cmp_Id=@New_Cmp_Id	
			DELETE FROM T0190_MONTHLY_PRESENT_IMPORT	    WHERE		EMP_ID  = @New_Emp_Id And cmp_Id=@New_Cmp_Id	
			DELETE FROM T0095_LEAVE_OPENING				    WHERE		EMP_ID  = @New_Emp_Id And cmp_Id=@New_Cmp_Id
			
			
			DELETE FROM T0140_BOND_TRANSACTION			    WHERE		EMP_ID  = @New_Emp_Id And cmp_Id=@New_Cmp_Id -- ADDED BY RAJPUT ON 05122018
			
			Declare @Leave_Approval_ID as numeric(18,0)

			Select @Leave_Approval_ID=Leave_Approval_ID FROM T0120_LEAVE_APPROVAL	WITH (NOLOCK)			WHERE		EMP_ID = @New_Emp_Id And cmp_Id=@New_Cmp_Id	
			DELETE FROM T0130_LEAVE_APPROVAL_DETAIL			WHERE		Leave_Approval_ID = @Leave_Approval_ID And cmp_Id=@New_Cmp_Id
			DELETE FROM T0120_LEAVE_APPROVAL				WHERE		EMP_ID = @New_Emp_Id And cmp_Id=@New_Cmp_Id
			
			Declare @DLogin_ID as numeric(18,0)
			Declare @DBranch_ID as numeric(18,0)
			Select @DLogin_ID=Login_ID ,@DBranch_ID = Branch_ID FROM T0011_Login	WITH (NOLOCK)	WHERE		EMP_ID = @New_Emp_Id And cmp_Id=@New_Cmp_Id
			
			Delete From T0011_LOGIN_HISTORY					WHERE		Login_ID  = @DLogin_ID And cmp_Id=@New_Cmp_Id  
			Delete From T0015_LOGIN_FORM_RIGHTS				WHERE		Login_ID  = @DLogin_ID And cmp_Id=@New_Cmp_Id  
			Delete From T0011_Login			                WHERE		Emp_ID  = @New_Emp_Id And cmp_Id=@New_Cmp_Id
			
			Delete From T0150_EMP_INOUT_RECORD              WHERE		Emp_ID  = @New_Emp_Id And cmp_Id=@New_Cmp_Id  
			Delete From T0100_IT_DECLARATION				WHERE		Emp_ID  = @New_Emp_Id And cmp_Id=@New_Cmp_Id  
			Delete From T0110_IT_Emp_Details				WHERE		Emp_ID  = @New_Emp_Id And cmp_Id=@New_Cmp_Id  
			DELETE from T0090_EMP_REFERENCE_DETAIL			WHERE		Emp_ID  = @New_Emp_Id And cmp_Id=@New_Cmp_Id
			DELETE from T0090_Emp_Medical_Checkup			WHERE		Emp_ID  = @New_Emp_Id And cmp_Id=@New_Cmp_Id	  
			--DELETE FROM dbo.T0080_EMP_MASTER	            WHERE       Emp_ID = @New_Emp_Id And cmp_Id=@New_Cmp_Id
			DELETE from T0090_EMP_REPORTING_DETAIL			WHERE		Emp_ID  = @New_Emp_Id And cmp_Id=@New_Cmp_Id --Added by Rajput 04072017	  
			DELETE FROM T0250_CHANGE_PASSWORD_HISTORY		WHERE		EMP_ID  = @NEW_EMP_ID AND CMP_ID=@NEW_CMP_ID --ADDED BY Krushna 26082019
		BEGIN TRY
			DELETE FROM dbo.T0080_EMP_MASTER	            WHERE       Emp_ID = @New_Emp_Id And cmp_Id=@New_Cmp_Id
		END TRY
		BEGIN CATCH
			RAISERROR ('Employee Reference Exists In New Company',16,2);
			return -1
		END CATCH;
			
			--''New Company Emp Delete and Old Company Emp Left Delete''--
			
			
RETURN



