

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[P_HRMS_HOME_DASHBOARD_NOTIFICATIONS]
	@Cmp_ID Int,  
    @Branch_ID Int,
    @Emp_id Int,
	@Privilage_ID int
AS

        SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON

BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.

    	create table #TBL_HRMS_LINKS_DASHBOARD
		(  
			RowNumber Int,
			Caption_Text varchar(1000),  
			Caption_URL varchar(1000),  
			IsPopup bit,
			Form_ID numeric(18, 0),
			Popup_Link_Class varchar(500),
			Popup_Class_Id varchar(500),
			PopupMethodID int
		)  

		declare @Forms_ID as Int =0
		declare @Form_url as varchar(max)
		Declare @Today_date date
		DECLARE @Desig_Id INT
		DECLARE @EmpBranch_ID INT
		set @Today_date=Getdate()

		declare @AllPrivilages table
		(   
			tran_id	numeric(19, 0)	,
			Privilage_ID	numeric(18, 0)	,
			cmp_id	numeric(18, 0)	,
			Form_ID	numeric(18, 0)	,
			Is_View	int	,
			is_edit	int	,
			is_save	int	,
			is_delete	int	,
			is_print	int	,
			Form_Name	varchar(100)	,
			Under_Form_ID	numeric(18, 0)	,
			Module_name	varchar(100)	,
			Page_Flag	char(2)	,
			Privilege_ID	int	,
			ExpiryDate	datetime
		);

	INSERT @AllPrivilages  
		Exec GET_EMP_PRIVILEGE @Cmp_ID=@Cmp_ID,@Privilege_Id=@Privilage_ID
			
		--select * from @AllPrivilages WHERE Form_Name='TD_Home_ESS_294'
		print 'a'
				--------Survey Forms-----------
				IF EXISTS (select 1 from @AllPrivilages where Form_Name='TD_Home_ESS_345' and (Is_View=1 or is_edit =1 or is_save =1 or is_delete=1))
				BEGIN
					SET @Forms_ID= (SELECT Form_ID FROM @AllPrivilages WHERE Form_Name='TD_Home_ESS_345')
					
					SELECT @Desig_Id=Desig_Id,@EmpBranch_ID=Branch_ID from V0080_EMP_MASTER_INCREMENT_GET where emp_id=@emp_id
										
					Declare @TotalSurvey as INT =0
					Select @TotalSurvey=Count(Survey_ID) from T0050_SurveyMaster WITH (NOLOCK) where Cmp_ID=@Cmp_ID and (@Emp_id in (SELECT cast(data AS numeric(18, 0)) FROM  dbo.Split(ISNULL(dbo.T0050_SurveyMaster.survey_empid, '0'), '#') WHERE data <> '')
					or @EmpBranch_ID = Branch_Id or  @desig_id  in (SELECT cast(data AS numeric(18, 0)) FROM  dbo.Split(ISNULL(dbo.T0050_SurveyMaster.desig_id, '0'), '#') WHERE data <> ''))
					and GETDATE() >= SurveyStart_Date and CAST(GETDATE() as varchar(12)) <= Survey_OpenTill
					PRINT @TotalSurvey
					
					IF (@TotalSurvey > 0)
					BEGIN
						Insert Into #TBL_HRMS_LINKS_DASHBOARD(RowNumber,Caption_Text,Caption_URL,IsPopup,Form_ID,Popup_Link_Class,Popup_Class_Id,PopupMethodID)
						values( 1,'Fill Up The Survey Form ','ess_surveyform.aspx',0,@Forms_ID,'N','N',-1 )
					--values( 1,'Fill Up The Survey Form ('+CAST(@TotalSurvey as varchar(12))+')','ess_surveyform.aspx',0,@Forms_ID,'N','N',-1 )
					
					END
				END
				-----end survey forms------


				IF EXISTS (select 1 from @AllPrivilages where Form_Name='TD_Home_ESS_288' and (Is_View=1 or is_edit =1 or is_save =1 or is_delete=1))
				BEGIN
					SET @Forms_ID= (SELECT Form_ID FROM @AllPrivilages WHERE Form_Name='TD_Home_ESS_288')

					Insert Into #TBL_HRMS_LINKS_DASHBOARD(RowNumber,Caption_Text,Caption_URL,IsPopup,Form_ID,Popup_Link_Class,Popup_Class_Id,PopupMethodID)
					values(2,'Given Training Feedback','ESS_TrainingFeedback.aspx',0,@Forms_ID,'N','N',-1)
				END

				IF EXISTS (select 1 from @AllPrivilages where Form_Name='TD_Home_ESS_297' and (Is_View=1 or is_edit =1 or is_save =1 or is_delete=1) )
				BEGIN
					SET @Forms_ID= (SELECT Form_ID FROM @AllPrivilages WHERE Form_Name='TD_Home_ESS_297')

					Insert Into #TBL_HRMS_LINKS_DASHBOARD(RowNumber,Caption_Text,Caption_URL,IsPopup,Form_ID,Popup_Link_Class,Popup_Class_Id,PopupMethodID)
					values(3,'Training Questionaries','Ess_TrainingAnswers.aspx',0,@Forms_ID,'N','N',-1)
				END

				IF EXISTS (select 1 from @AllPrivilages where Form_Name='TD_Home_ESS_298' and (Is_View=1 or is_edit =1 or is_save =1 or is_delete=1) )
				BEGIN
					SET @Forms_ID= (SELECT Form_ID FROM @AllPrivilages WHERE Form_Name='TD_Home_ESS_298')

					Insert Into #TBL_HRMS_LINKS_DASHBOARD(RowNumber,Caption_Text,Caption_URL,IsPopup,Form_ID,Popup_Link_Class,Popup_Class_Id,PopupMethodID)
					values(4,'OJT pending for last month joinees','javascript:void(0);',1,@Forms_ID,'lnkPopupopen','empnotications',0)
				END

				IF EXISTS (select 1 from @AllPrivilages where Form_Name='TD_Home_ESS_299' and (Is_View=1 or is_edit =1 or is_save =1 or is_delete=1))
				BEGIN
					SET @Forms_ID= (SELECT Form_ID FROM @AllPrivilages WHERE Form_Name='TD_Home_ESS_299')

					Insert Into #TBL_HRMS_LINKS_DASHBOARD(RowNumber,Caption_Text,Caption_URL,IsPopup,Form_ID,Popup_Link_Class,Popup_Class_Id,PopupMethodID)
					values(5,'OJT pending since last year','javascript:void(0);',1,@Forms_ID,'lnkPopupopen','empnotications',1)
				END

				IF EXISTS (select 1 from @AllPrivilages where Form_Name='TD_Home_ESS_311' and (Is_View=1 or is_edit =1 or is_save =1 or is_delete=1))
				BEGIN
					SET @Forms_ID= (SELECT Form_ID FROM @AllPrivilages WHERE Form_Name='TD_Home_ESS_311')

					Insert Into #TBL_HRMS_LINKS_DASHBOARD(RowNumber,Caption_Text,Caption_URL,IsPopup,Form_ID,Popup_Link_Class,Popup_Class_Id,PopupMethodID)
					values(6,'Recruitment Openings','View_Current_Open.aspx',0,@Forms_ID,'N','N',-1)
				END

				

				/*My Team  commneted as per sandipbhai dicussion repetaed things

				IF EXISTS (select 1 from @AllPrivilages where Form_Name='TD_Home_ESS_263' and (Is_View=1 or is_edit =1 or is_save =1 or is_delete=1))
				BEGIN
					SET @Forms_ID= (SELECT Form_ID FROM @AllPrivilages WHERE Form_Name='TD_Home_ESS_263') 

					Insert Into #TBL_HRMS_LINKS_DASHBOARD(RowNumber,Caption_Text,Caption_URL,IsPopup,Form_ID,Popup_Link_Class,Popup_Class_Id,PopupMethodID)
					values(7,'My Team','Dashboard_Employee.aspx',0,@Forms_ID,'N','N',-1)
				END
				*/

				--new added 10-oct-2019
				IF EXISTS (select 1 from @AllPrivilages where Form_Name='TD_Home_ESS_285' and (Is_View=1 or is_edit =1 or is_save =1 or is_delete=1))
				BEGIN
				Insert Into #TBL_HRMS_LINKS_DASHBOARD(RowNumber,Caption_Text,Caption_URL,IsPopup,Form_ID,Popup_Link_Class,Popup_Class_Id,PopupMethodID)
				values(8,'About Me','javascript:void(0);',0,@Forms_ID,'lnkPopupopen','empnotications',2)
				end

				IF EXISTS (select 1 from @AllPrivilages where Form_Name='TD_Home_ESS_268' and (Is_View=1 or is_edit =1 or is_save =1 or is_delete=1))
				BEGIN					
					SET @Forms_ID= (SELECT Form_ID FROM @AllPrivilages WHERE Form_Name='TD_Home_ESS_268')
				Insert Into #TBL_HRMS_LINKS_DASHBOARD(RowNumber,Caption_Text,Caption_URL,IsPopup,Form_ID,Popup_Link_Class,Popup_Class_Id,PopupMethodID)
				values(9,'Attendance Summary','Emp_Inout_New.aspx',0,@Forms_ID,'N','N',-1)

				END


				IF EXISTS (select 1 from @AllPrivilages where Form_Name='TD_Home_ESS_269' and (Is_View=1 or is_edit =1 or is_save =1 or is_delete=1))
				BEGIN					
					SET @Forms_ID= (SELECT Form_ID FROM @AllPrivilages WHERE Form_Name='TD_Home_ESS_269')
				Insert Into #TBL_HRMS_LINKS_DASHBOARD(RowNumber,Caption_Text,Caption_URL,IsPopup,Form_ID,Popup_Link_Class,Popup_Class_Id,PopupMethodID)
				values(10,'Employee History','ESS_Employee_History.aspx',0,@Forms_ID,'N','N',-1)

				END

				--comented due to as per hardikbhai suggestion due not need it
				--IF EXISTS (select 1 from @AllPrivilages where Form_Name='TD_Home_ESS_270' and (Is_View=1 or is_edit =1 or is_save =1 or is_delete=1))
				--BEGIN
				--	Insert Into #TBL_HRMS_LINKS_DASHBOARD(RowNumber,Caption_Text,Caption_URL,IsPopup,Form_ID,Popup_Link_Class,Popup_Class_Id,PopupMethodID)
				--	values(11,'Current Year Salary Detail','javascript:void(0);',0,@Forms_ID,'lnkPopupopen','Current_Year_Salary_Detail',3)	
				--end

				IF EXISTS (select 1 from @AllPrivilages where Form_Name='TD_Home_ESS_270' and (Is_View=1 or is_edit =1 or is_save =1 or is_delete=1))
				BEGIN
					Insert Into #TBL_HRMS_LINKS_DASHBOARD(RowNumber,Caption_Text,Caption_URL,IsPopup,Form_ID,Popup_Link_Class,Popup_Class_Id,PopupMethodID)
					values(12,'Holiday Calendar','javascript:void(0);',0,@Forms_ID,'lnkPopupopen','Holiday_Calendar',4)	
				end
			
				-- Added by Divyaraj Kiri on 18/06/2024

				IF EXISTS (select 1 from @AllPrivilages where Form_Name='TD_Home_ESS_275' and (Is_View=1 or is_edit =1 or is_save =1 or is_delete=1))
				BEGIN
					Insert Into #TBL_HRMS_LINKS_DASHBOARD(RowNumber,Caption_Text,Caption_URL,IsPopup,Form_ID,Popup_Link_Class,Popup_Class_Id,PopupMethodID)
					values(13,'exit interview scheduled','My_ExitInterview.aspx',1,@Forms_ID,'N','N',-1)	
				end

				-- Ended by Divyaraj Kiri on 18/06/2024

					-- Added by Deepali -21102024
					IF EXISTS (select 1 from @AllPrivilages where Form_Name='TD_Home_ESS_355' and (Is_View=1 or is_edit =1 or is_save =1 or is_delete=1))
				BEGIN
					Insert Into #TBL_HRMS_LINKS_DASHBOARD(RowNumber,Caption_Text,Caption_URL,IsPopup,Form_ID,Popup_Link_Class,Popup_Class_Id,PopupMethodID)
					values(14,'My KPA / Goal','Ess_EmployeeKPA.aspx',1,@Forms_ID,'N','N',-1)	
				end

				IF EXISTS (select 1 from @AllPrivilages where Form_Name='TD_Home_ESS_356' and (Is_View=1 or is_edit =1 or is_save =1 or is_delete=1))
				BEGIN
					Insert Into #TBL_HRMS_LINKS_DASHBOARD(RowNumber,Caption_Text,Caption_URL,IsPopup,Form_ID,Popup_Link_Class,Popup_Class_Id,PopupMethodID)
					values(15,'Employee KPA Approval','Ess_EmployeeKPA_Approval.aspx',1,@Forms_ID,'N','N',-1)	
				end
				--End by Deepali -21102024
				--IF EXISTS (select 1 from @AllPrivilages where Form_Name='TD_Home_ESS_272' and (Is_View=1 or is_edit =1 or is_save =1 or is_delete=1))
				--BEGIN
				--	Insert Into #TBL_HRMS_LINKS_DASHBOARD(RowNumber,Caption_Text,Caption_URL,IsPopup,Form_ID,Popup_Link_Class,Popup_Class_Id,PopupMethodID)
				--	values(13,'Leave Balance','javascript:void(0);',0,@Forms_ID,'lnkPopupopen','Leave_Balance',5)	
				--end
				
				IF EXISTS (select 1 from @AllPrivilages where Form_Name='TD_Home_ESS_278' and (Is_View=1 or is_edit =1 or is_save =1 or is_delete=1))
				BEGIN
						Declare @Emp_Cons Table        
							 (        
							  Emp_ID numeric        
							 )
							 
							declare @to_date as datetime
							set @to_date = GETDATE()   
							  Insert Into @Emp_Cons(Emp_ID)        
        
							select I.Emp_Id from T0095_Increment I WITH (NOLOCK) inner join         
							( select max(Increment_Id) as Increment_Id , Emp_ID From T0095_Increment WITH (NOLOCK)       
							where Increment_Effective_date <= @To_Date        
							and Cmp_ID = @Cmp_ID        
							group by emp_ID  ) Qry on        
							I.Emp_ID = Qry.Emp_ID and I.Increment_Id = Qry.Increment_Id         
               
						   Where Cmp_ID = @Cmp_ID                 
						   and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID)  

					if Exists(SELECT 1 FROM T0040_DOCUMENT_MASTER DM WITH (NOLOCK)
								CROSS JOIN T0080_EMP_MASTER EM WITH (NOLOCK)
								LEFT OUTER JOIN T0090_EMP_DOC_DETAIL EDD WITH (NOLOCK) ON EDD.DOC_ID = DM.DOC_ID AND EM.EMP_ID = EDD.EMP_ID
								inner join @Emp_Cons EC on ec.Emp_ID = em.Emp_ID
							 WHERE DM.CMP_ID = @Cmp_ID AND DOC_REQUIRED = 1 and isnull(EDD.Doc_Path,'0')='0')
					BEGIN
					--print 'afgf'
						Set @Forms_ID=0
						Insert Into #TBL_HRMS_LINKS_DASHBOARD(RowNumber,Caption_Text,Caption_URL,IsPopup,Form_ID,Popup_Link_Class,Popup_Class_Id,PopupMethodID)
						values(14,'Pending Document''s List','javascript:void(0);',0,@Forms_ID,'lnkPopupopen','Pending_Documents',6)	
					end
				end
				
				
				IF EXISTS (select 1 from @AllPrivilages where Form_Name='TD_Home_ESS_269' and (Is_View=1 or is_edit =1 or is_save =1 or is_delete=1))
				BEGIN					
					SET @Forms_ID= (SELECT Form_ID FROM @AllPrivilages WHERE Form_Name='TD_Home_ESS_269')
				Insert Into #TBL_HRMS_LINKS_DASHBOARD(RowNumber,Caption_Text,Caption_URL,IsPopup,Form_ID,Popup_Link_Class,Popup_Class_Id,PopupMethodID)
				values(15,'Warning Details','Employee_Warning.aspx',0,@Forms_ID,'N','N',-1)

				END
				
				IF EXISTS (select 1 from @AllPrivilages where Form_Name='TD_Home_Ess_289' and (Is_View=1 or is_edit =1 or is_save =1 or is_delete=1))
				BEGIN					
					SET @Forms_ID= (SELECT Form_ID FROM @AllPrivilages WHERE Form_Name='TD_Home_Ess_289')
				Insert Into #TBL_HRMS_LINKS_DASHBOARD(RowNumber,Caption_Text,Caption_URL,IsPopup,Form_ID,Popup_Link_Class,Popup_Class_Id,PopupMethodID)
				values(15,'WhosOff','WhosOffInMyTeam.aspx',0,@Forms_ID,'N','N',-1)

				END

				---prapti 342022
				IF EXISTS (select 1 from @AllPrivilages where Form_Name='TD_Home_ESS_341' and (Is_View=1 or is_edit =1 or is_save =1 or is_delete=1))
				BEGIN					
					SET @Forms_ID= (SELECT Form_ID FROM @AllPrivilages WHERE Form_Name='TD_Home_ESS_341')
				Insert Into #TBL_HRMS_LINKS_DASHBOARD(RowNumber,Caption_Text,Caption_URL,IsPopup,Form_ID,Popup_Link_Class,Popup_Class_Id,PopupMethodID)
				values(15,'Reward your team','Ess_HRMS_EmployeeReward.aspx',0,@Forms_ID,'N','N',-1)

				END
				
				IF EXISTS (select 1 from @AllPrivilages where Form_Name='TD_Home_ESS_279' and (Is_View=1 or is_edit =1 or is_save =1 or is_delete=1))
				BEGIN	
								
					SET @Forms_ID= (SELECT Form_ID FROM @AllPrivilages WHERE Form_Name='TD_Home_ESS_279')

					Insert Into #TBL_HRMS_LINKS_DASHBOARD(RowNumber,Caption_Text,Caption_URL,IsPopup,Form_ID,Popup_Link_Class,Popup_Class_Id,PopupMethodID)
					values(16,'View Graphical Report','Graphical_chart_Ess.aspx',0,@Forms_ID,'N','N',-1)

				END

				
				
				--Fill Self Assessment  --- Changed By Deepali - 08092022
				IF EXISTS (select 1 from @AllPrivilages where Form_Name='TD_Home_ESS_294' and (Is_View=1 or is_edit =1 or is_save =1 or is_delete=1))
				BEGIN	
					Declare @InitiateId as INT
					

					
					IF EXISTS (select 1 from T0050_HRMS_InitiateAppraisal WITH (NOLOCK) where Emp_Id=@Emp_id and (SA_Startdate <= @Today_date and SA_Enddate >=@Today_date and SA_Status<>1 ) and SA_SendToRM <> 1)
						BEGIN	
							SET @Forms_ID= (SELECT Form_ID FROM @AllPrivilages WHERE Form_Name='TD_Home_ESS_294')

							Select	@Form_url=(case when Form_url = null or Form_url = '' 
										then 'SelfAppraisal_Form.aspx' 
									else Form_url 
									end) 
							from	T0000_DEFAULT_FORM WITH (NOLOCK)
							where	Form_Name='TD_Home_ESS_294'

							Select @InitiateId=isnull(InitiateId,0) from T0050_HRMS_InitiateAppraisal WITH (NOLOCK)
							where Emp_Id =@Emp_id and (SA_Startdate <= @Today_date  and  SA_Enddate >=@Today_date  and SA_Status<>1 ) and SA_SendToRM <> 1

							IF @InitiateId > 0
							BEGIN

								Set	@Form_url=@Form_url+'?Initid=' + cast(@InitiateId as varchar(11))
							
								Insert Into #TBL_HRMS_LINKS_DASHBOARD(RowNumber,Caption_Text,Caption_URL,IsPopup,Form_ID,Popup_Link_Class,Popup_Class_Id,PopupMethodID)
								values(17,'Self Assessment Form',@Form_url,1,@Forms_ID,'N','N',-1) --Changes by Deepali 17082022

							END
						END
				END
			--Fill Self Assessment

			IF EXISTS (select 1 from @AllPrivilages where Form_Name='TD_Home_ESS_314' and (Is_View=1 or is_edit =1 or is_save =1 or is_delete=1))
			BEGIN			
					SET @Forms_ID= (SELECT Form_ID FROM @AllPrivilages WHERE Form_Name='TD_Home_ESS_314')

					Insert Into #TBL_HRMS_LINKS_DASHBOARD(RowNumber,Caption_Text,Caption_URL,IsPopup,Form_ID,Popup_Link_Class,Popup_Class_Id,PopupMethodID)
					values(314,'Fill Self Assessment Probation Form',@Form_url,0,@Forms_ID,'N','N',-1)

			END
		
			IF EXISTS (select 1 from @AllPrivilages where Form_Name='My KPA' and (Is_View=1 or is_edit =1 or is_save =1 or is_delete=1))
			BEGIN			
					SET @Forms_ID= (SELECT Form_ID FROM @AllPrivilages WHERE Form_Name='My KPA')
					Insert Into #TBL_HRMS_LINKS_DASHBOARD(RowNumber,Caption_Text,Caption_URL,IsPopup,Form_ID,Popup_Link_Class,Popup_Class_Id,PopupMethodID)
					values(316,'My KPA','Ess_EmployeeKPA.aspx',1,@Forms_ID,'N','N',-1)

			END

			IF EXISTS (select 1 from @AllPrivilages where Form_Name='TD_Home_ESS_317' and (Is_View=1 or is_edit =1 or is_save =1 or is_delete=1))
			BEGIN			
					SET @Forms_ID= (SELECT Form_ID FROM @AllPrivilages WHERE Form_Name='TD_Home_ESS_317')
					Insert Into #TBL_HRMS_LINKS_DASHBOARD(RowNumber,Caption_Text,Caption_URL,IsPopup,Form_ID,Popup_Link_Class,Popup_Class_Id,PopupMethodID)
					values(317,'Induction Training Questionaries','Ess_Induction_TrainingAnswers.aspx',0,@Forms_ID,'N','N',-1)
			END

			--IF EXISTS (select 1 from @AllPrivilages where Form_Name='TD_Home_ESS_318' and (Is_View=1 or is_edit =1 or is_save =1 or is_delete=1))
			--BEGIN			
			--		SET @Forms_ID= (SELECT Form_ID FROM @AllPrivilages WHERE Form_Name='TD_Home_ESS_318')
			--		Insert Into #TBL_HRMS_LINKS_DASHBOARD(RowNumber,Caption_Text,Caption_URL,IsPopup,Form_ID,Popup_Link_Class,Popup_Class_Id,PopupMethodID)
			--		values(318,'Fill Functional Checklist',@Form_url,0,@Forms_ID,'N','N',-1)
			--END

			--IF EXISTS (select 1 from @AllPrivilages where Form_Name='TD_Home_ESS_319' and (Is_View=1 or is_edit =1 or is_save =1 or is_delete=1))
			--BEGIN			
			--		SET @Forms_ID= (SELECT Form_ID FROM @AllPrivilages WHERE Form_Name='TD_Home_ESS_319')
			--		Insert Into #TBL_HRMS_LINKS_DASHBOARD(RowNumber,Caption_Text,Caption_URL,IsPopup,Form_ID,Popup_Link_Class,Popup_Class_Id,PopupMethodID)
			--		values(319,'Functional Induction Training Checklist',@Form_url,0,@Forms_ID,'N','N',-1)

			--END

			IF EXISTS (select 1 from @AllPrivilages where Form_Name='TD_Home_ESS_307' and (Is_View=1 or is_edit =1 or is_save =1 or is_delete=1))
			BEGIN			
					SET @Forms_ID= (SELECT Form_ID FROM @AllPrivilages WHERE Form_Name='TD_Home_ESS_307')
					Insert Into #TBL_HRMS_LINKS_DASHBOARD(RowNumber,Caption_Text,Caption_URL,IsPopup,Form_ID,Popup_Link_Class,Popup_Class_Id,PopupMethodID)
					values(307,'Training Manager Feedback','ESS_Manager_TrainingFeedback.aspx',0,@Forms_ID,'N','N',-1)

			END

			--IF EXISTS (select 1 from @AllPrivilages where Form_Name='Timesheet Approval' and (Is_View=1 or is_edit =1 or is_save =1 or is_delete=1))
			--	BEGIN
			--		SET @Forms_ID= (SELECT Form_ID FROM @AllPrivilages WHERE Form_Name='Timesheet Approval')

			--		Insert Into #TBL_HRMS_LINKS_DASHBOARD(RowNumber,Caption_Text,Caption_URL,IsPopup,Form_ID,Popup_Link_Class,Popup_Class_Id,PopupMethodID)
			--		values(318,'Timesheet Approval','Timesheet_Approval.aspx',0,@Forms_ID,'N','N',-1)
			--	END

				--Added by Mehul 22092022
				IF EXISTS (select 1 from @AllPrivilages where Form_Name='TD_Home_ESS_290' and (Is_View=1 or is_edit =1 or is_save =1 or is_delete=1))
				BEGIN					
					SET @Forms_ID= (SELECT Form_ID FROM @AllPrivilages WHERE Form_Name='TD_Home_ESS_290')
					Insert Into #TBL_HRMS_LINKS_DASHBOARD(RowNumber,Caption_Text,Caption_URL,IsPopup,Form_ID,Popup_Link_Class,Popup_Class_Id,PopupMethodID)
					values(318,'Timesheet Approval','Timesheet_Approval.aspx',1,@Forms_ID,'lnkPopupopen','empnotications',1)
				End


			--IF EXISTS (select 1 from @AllPrivilages where Form_Name='TD_Home_Ess_342' and (Is_View=1 or is_edit =1 or is_save =1 or is_delete=1))
			--BEGIN			
			--	--Select @Form_url as Form_url
			--		SET @Forms_ID= (SELECT Form_ID FROM @AllPrivilages WHERE Form_Name='TD_Home_Ess_342')
			--		Insert Into #TBL_HRMS_LINKS_DASHBOARD(RowNumber,Caption_Text,Caption_URL,IsPopup,Form_ID,Popup_Link_Class,Popup_Class_Id,PopupMethodID)
			--		values(342,'Change Request Approval',@Form_url,0,@Forms_ID,'N','N',-1)

			--END

			--My Appraisal Notification
		

			--	IF EXISTS (select 1 from @AllPrivilages where Form_Name='TD_Home_ESS_292' and (Is_View=1 or is_edit =1 or is_save =1 or is_delete=1))
			--	BEGIN
					
			--		IF EXISTS(SELECT 1 FROM V0090_hrms_appraisal_status_Report 
			--						WHERE	Emp_ID=@Emp_ID and Is_Accept=2 and Invoke_Emp=2 and ISNULL(Inspection_Status,0)=0) 
			--			BEGIN

			--					Insert Into #TBL_HRMS_LINKS_DASHBOARD(RowNumber,Caption_Text,Caption_URL,IsPopup,Form_ID,Popup_Link_Class,Popup_Class_Id,PopupMethodID)
			--					values(18,'Your Appraisal is invoked. Kindly fill detail to make it effective.',@Form_url,0,@Forms_ID,'N','N',-1)

			--		    END
			--	END
			
			----My Appraisal Notification

			----Appraisal Notification for Team

			--	IF EXISTS (select 1 from @AllPrivilages where Form_Name='TD_Home_ESS_293' and (Is_View=1 or is_edit =1 or is_save =1 or is_delete=1))
			--	BEGIN
					
			--		IF EXISTS(SELECT 1 From V0090_Hrms_Emp_Sup_DashBoard
			--							 where Emp_Superior=@Emp_ID and cmp_Id=@Cmp_ID And Is_Sup_Submit = 2) 
			--			BEGIN

			--					Insert Into #TBL_HRMS_LINKS_DASHBOARD(RowNumber,Caption_Text,Caption_URL,IsPopup,Form_ID,Popup_Link_Class,Popup_Class_Id,PopupMethodID)
			--					values(19,'Your Appraisal is invoked. Kindly fill detail to make it effective.',@Form_url,0,@Forms_ID,'N','N',-1)

			--		    END
			--	END

		 --  --Appraisal Notification for Team
				

			--	DECLARE @KPA_Default as INT
			--	set @KPA_Default = 0
			--	Select top 1 @KPA_Default=KPA_Default from T0050_AppraisalLimit_Setting where cmp_id=@Cmp_ID ORDER by Limit_Id desc


			--	-------------SelfAssessmentForm_Pending------------

			--	DECLARE @initcount INT = 0
			--	Set @Form_url=''

			--	IF EXISTS (select 1 from @AllPrivilages where Form_Name='TD_Home_ESS_295' and (Is_View=1 or is_edit =1 or is_save =1 or is_delete=1))
			--	BEGIN
			--			SELECT @initcount = COUNT(i.InitiateId) 
			--			FROM  T0050_HRMS_InitiateAppraisal I INNER JOIN
			--			T0090_EMP_REPORTING_DETAIL ERD on ERD.Emp_ID = i.Emp_Id
			--			 INNER JOIN 
			--			(
			--				SELECT MAX(Row_ID)Row_ID,T0090_EMP_REPORTING_DETAIL.Emp_ID FROM
			--				T0090_EMP_REPORTING_DETAIL INNER JOIN
			--				(
			--					SELECT MAX(Effect_Date)Effect_Date,T0090_EMP_REPORTING_DETAIL.Emp_ID
			--					FROM T0090_EMP_REPORTING_DETAIL INNER JOIN
			--						 T0050_HRMS_InitiateAppraisal IA ON IA.Emp_Id = T0090_EMP_REPORTING_DETAIL.Emp_ID
			--					WHERE Effect_Date<= IA.SA_Startdate AND ((SA_Status=0) or (SA_Status=1 and Overall_Status=8) or (SA_Status=1 and Overall_Status=9))
			--					GROUP by T0090_EMP_REPORTING_DETAIL.Emp_ID
			--				)ERD1 ON ERD1.Emp_ID = T0090_EMP_REPORTING_DETAIL.Emp_ID
			--				GROUP BY T0090_EMP_REPORTING_DETAIL.Emp_ID
			--			)ERD2 ON ERD2.Row_ID = erd.Row_ID AND ERD2.Emp_ID = ERD.Emp_ID
			--			WHERE ERD.R_Emp_ID = @emp_id AND ((SA_Status=0) or (I.SA_Status=1 and I.Overall_Status=8) or (I.SA_Status=1 and I.Overall_Status=9))
			--			--CASE WHEN @KPA_Default=1 THEN SA_Status=0 ELSE SA_STATUS IN(0,1) AND (Overall_Status=9 OR Overall_Status IS NULL) END 
			--			AND DATEPART(YYYY,SA_Startdate) =DATEPART(YYYY,GETDATE())
				
				
				
			--			SELECT @Form_url=(CASE WHEN isnull(Form_url,'Ess_EmpAssessment.aspx') <> '' THEN Form_url 
			--								   WHEN @KPA_Default=1 THEN 'Ess_EmpAssessment.aspx' 
			--								   ELSE 'Ess_PerformanceAssessment.aspx' 
			--							  END) 
			--			FROM T0000_DEFAULT_FORM WHERE Form_Name='TD_Home_ESS_295'	

			--			Insert Into #TBL_HRMS_LINKS_DASHBOARD(RowNumber,Caption_Text,Caption_URL,IsPopup,Form_ID,Popup_Link_Class,Popup_Class_Id,PopupMethodID)
			--			values(20,'Employee Assessment Pending('+CAST(@initcount as varchar(10))+')',@Form_url,0,@Forms_ID,'N','N',-1)

			--	END
			------------------------------------------------------


			-----------------AppraisalFinalization() HOD/GH------- by Deepali -03092022
			DECLARE @Alpha_Emp_Code varchar(50) 
			declare @initcount  as int 
			SELECT	@Alpha_Emp_Code =Alpha_Emp_Code FROM T0080_EMP_MASTER WHERE Emp_ID = @emp_id
			SET @initcount  =0 
			IF EXISTS (select 1 from @AllPrivilages where Form_Name='TD_Home_ESS_296' and (Is_View=1 or is_edit =1 or is_save =1 or is_delete=1))
			BEGIN
				Set @Form_url=''

				SELECT @initcount = COUNT(InitiateId) 
				FROM V0050_HRMS_InitiateAppraisal 
				WHERE  DATEPART(YYYY,SA_Startdate) = DATEPART(YYYY,GETDATE()) AND 
				(Overall_Status=11 or Overall_Status =(CASE WHEN (ISNULL(SendToHOD,0) =1 and Overall_Status =0) 
				THEN null WHEN (isnull(SendToHOD,0) = 0 and Overall_Status=0) THEN Overall_Status WHEN (isnull(SendToHOD,0) = 1 and Overall_Status=6) THEN Overall_Status END))  
				AND GH_Id = @emp_id
				--And Old_Ref_No=@Alpha_Emp_Code
			--	Select count(InitiateId) AS InitiateId from V0050_HRMS_InitiateAppraisal where  DATEPART(YYYY,SA_Startdate) =" & DateTime.Now.Year & " AND Overall_Status =(case when (isnull(SendToHOD,0) =1 and Overall_Status =0) then null when (isnull(SendToHOD,0) = 0 and Overall_Status=0) then Overall_Status when (isnull(SendToHOD,0) = 1 and Overall_Status=6) then Overall_Status end )  And gh_id=@emp_id
			
				SELECT @Form_url=CASE WHEN isnull(Form_url,'Ess_AppraisalFinalization.aspx')<>'' THEN Form_url  ELSE 'Ess_AppraisalFinalization.aspx' END
				FROM T0000_DEFAULT_FORM 
				WHERE Form_Name='TD_Home_ESS_296'	
			
				Insert Into #TBL_HRMS_LINKS_DASHBOARD(RowNumber,Caption_Text,Caption_URL,IsPopup,Form_ID,Popup_Link_Class,Popup_Class_Id,PopupMethodID)
			    values(21,'Employee/s For Group Head/GH Approval('+CAST(@initcount as varchar(10))+')',@Form_url,1,@Forms_ID,'N','N',-1)
			END	

			IF EXISTS (select 1 from @AllPrivilages where Form_Name='TD_Home_ESS_350' and (Is_View=1 or is_edit =1 or is_save =1 or is_delete=1))
			BEGIN

				Set @Form_url=''

				SELECT @initcount =count(DISTINCT InitiateId) --AS InitiateId 
				FROM V0050_HRMS_InitiateAppraisal V INNER JOIN
					 T0095_INCREMENT inc on inc.Emp_ID = v.Emp_Id INNER JOIN
					 (
						SELECT max(Increment_ID)Increment_ID,T0095_INCREMENT.Emp_ID
						FROM T0095_INCREMENT INNER JOIN
						(
							SELECT max(Increment_Effective_Date)Increment_Effective_Date,T0095_INCREMENT.Emp_ID
							FROM T0095_INCREMENT INNER JOIN
								 T0050_HRMS_InitiateAppraisal I on i.Emp_Id = T0095_INCREMENT.Emp_ID
							WHERE T0095_INCREMENT.Cmp_ID =@Cmp_ID and Increment_Effective_Date <= I.SA_Startdate
							GROUP by T0095_INCREMENT.Emp_ID
						)inc1 ON inc1.Emp_ID = T0095_INCREMENT.Emp_ID
						WHERE Cmp_ID = @Cmp_ID
						GROUP BY T0095_INCREMENT.Emp_ID
					 )inc2 ON inc2.Increment_ID = inc.Increment_ID and inc2.Emp_ID = inc.Emp_ID LEFT JOIN
					 T0095_Department_Manager DM on DM.Dept_Id = inc.Dept_ID LEFT JOIN
					 (
						SELECT max(Effective_Date)Effective_Date,Dept_Id
						FROM T0095_Department_Manager	
						WHERE Cmp_id = @Cmp_ID
						GROUP BY Dept_Id
					 )DM1 ON DM1.Dept_Id = DM.Dept_Id
				WHERE DATEPART(YYYY,SA_Startdate) = DATEPART(YYYY,GETDATE()) and 
				(V.Overall_Status=2 or V.Overall_Status=10 or Overall_Status =(CASE WHEN SendToHOD =1 and Overall_Status =0 THEN Overall_Status when SendToHOD =0 and Overall_Status is not null then null else null end)) 
				and SendToHOD =1 and @emp_id = (CASE WHEN isnull(v.hod_id,0) <> 0  THEN v.hod_id ELSE dm.Emp_id END)
		 
				SELECT @Form_url=CASE WHEN isnull(Form_url,'Ess_ApprisalHODApproval.aspx')<>'' THEN Form_url  ELSE 'Ess_ApprisalHODApproval.aspx' END
				FROM T0000_DEFAULT_FORM 
				WHERE Form_Name='TD_Home_ESS_350'	

				Insert Into #TBL_HRMS_LINKS_DASHBOARD(RowNumber,Caption_Text,Caption_URL,IsPopup,Form_ID,Popup_Link_Class,Popup_Class_Id,PopupMethodID)
			    values(22,'Employee/s For Group Head/GH Approval('+CAST(@initcount as varchar(10))+')',@Form_url,1,@Forms_ID,'N','N',-1)
			END
			------------------------------------------------------
			--Declare @Message as varchar(max)

			-----Need To Put --Provilage and other settings -- 24102019

			-----------------Apprisal_Alert-----------------
			--DECLARE @sch_date_tmp varchar(10)
			--DECLARE @sch_date datetime


			--DECLARE @KPI_month		int
			--DECLARE @KPI_AlertDay  int
			--DECLARE @KPI_AlertNoDays  int
			--DECLARE @KPI_AlertType  int

			--DECLARE @KPI_month_str		varchar(3)
			--DECLARE @KPI_AlertDay_str  varchar(3)

			--DECLARE @cur_month  Integer
			--DECLARE @cur_day  Integer
			--DECLARE @day_alerttill  Integer

			--SET @cur_month = DATEPART(month,GETDATE())
			--SET @cur_day = DATEPART(DAY,GETDATE())
			
			--declare @msg as int 
			--SET @msg = 0
			
			--DECLARE cur CURSOR
			--FOR	
			--	SELECT KPI_Month,KPI_AlertDay,KPI_AlertNodays,KPI_AlertType
			--	FROM T0040_KPI_AlertSetting WHERE Cmp_Id=@cmp_Id and KPI_Type=1 
			--OPEN cur
			--	FETCH NEXT FROM cur INTO @KPI_Month,@KPI_AlertDay,@KPI_AlertNodays,@KPI_AlertType
			--	WHILE @@fetch_status = 0
			--		BEGIN
			--			SET @KPI_month_str = @KPI_Month
			--			SET @KPI_AlertDay_str = @KPI_AlertDay
						
			--			SELECT @sch_date_tmp = cast(datepart(YEAR,GETDATE()) as varchar(4)) +'-'+case when  LEN(@KPI_Month) > 1 then @KPI_month_str else '0'+ @KPI_month_str  end+'-'+ case when  LEN(@KPI_AlertDay) > 1 then @KPI_AlertDay_str else '0'+ @KPI_AlertDay_str  end
						
			--			if len(@KPI_AlertDay) > 1   --Added by Jaina 08-03-2018 ( if alertday 0 that time date set as 2018-02-00)
			--				SET @sch_date = DATEADD(DAY,@KPI_AlertNoDays,convert(DATETIME,@sch_date_tmp))
					
			--			--SELECT @sch_date_tmp,@sch_date
			--			IF @cur_month = @KPI_month 
			--				BEGIN
			--					SET @day_alerttill =@KPI_AlertDay + @KPI_AlertNoDays
			--					IF @cur_day >= @KPI_AlertDay And @cur_day <= @day_alerttill
			--						BEGIN
			--							set @msg =1
			--							BREAK;
			--						END	
			--					ELSE
			--						BEGIN
			--							set @msg =0
			--						END				
			--				END	
			--			ELSE IF @cur_month = DATEPART(MONTH,@sch_date)
			--				BEGIN
			--					IF @cur_day <= DATEPART(DAY,@sch_date)
			--						BEGIN
			--							SET @msg =1
			--							BREAK;
			--						END	
			--					ELSE
			--						BEGIN
			--							SET @msg = 0
			--						END					
			--				END	
			--			ELSE If @cur_month > @KPI_month And @cur_month < DATEPART(MONTH,@sch_date)
			--				BEGIN
			--					SET @msg =1
			--					BREAK;							
			--				END
			--			ELSE
			--				BEGIN
			--					SET @msg = 0
			--				END	
							
			--			FETCH NEXT FROM cur INTO @KPI_Month,@KPI_AlertDay,@KPI_AlertNodays,@KPI_AlertType
			--		END				
			--CLOSE cur
			--DEALLOCATE cur
			
			--IF @msg  = 1
			--	BEGIN
			--		SELECT @Message= 'Start the ' + case when @KPI_AlertType =1 then 'Interim' else 'Final' end + ' Appraisal process' ,
			--			@Form_url=(CASE WHEN isnull(Form_url,'Ess_KPI_PMS_AppraisalForm.aspx')<>'' THEN Form_url  ELSE 'Ess_KPI_PMS_AppraisalForm.aspx' END )
			--		FROM T0000_DEFAULT_FORM 
			--		WHERE (Form_Name='ESS Employee Goal Assessment' or Form_Name ='KPI Apparisal Form') and page_Flag= 'EP' and Is_Active_For_menu = 1

			--		Insert Into #TBL_HRMS_LINKS_DASHBOARD(RowNumber,Caption_Text,Caption_URL,IsPopup,Form_ID,Popup_Link_Class,Popup_Class_Id,PopupMethodID)
			--		values(23,@Message,@Form_url,0,@Forms_ID,'N','N',-1)
			--	END
			----ELSE
			----	SELECT 0 as response

			-------------------------------------------------------			
			--------------Appraisal Notify-------------------------
			--DECLARE @KPIPMS_Status  INT = 0
			--SELECT  @KPIPMS_Status = isnull(KPIPMS_Status,0) 
			--FROM    T0080_KPIPMS_EVAL 
			--WHERE   cmp_id=@cmp_id and emp_id= @emp_id  and kpipms_status=1
			--If @KPIPMS_Status =1
			--	BEGIN
			--		SELECT @Message='Approve your KPI rating',@Form_url='Ess_KPI_PMS_AppraisalForm.aspx'

			--		Insert Into #TBL_HRMS_LINKS_DASHBOARD(RowNumber,Caption_Text,Caption_URL,IsPopup,Form_ID,Popup_Link_Class,Popup_Class_Id,PopupMethodID)
			--		values(24,@Message,@Form_url,0,@Forms_ID,'N','N',-1)
			--	END
			----ELSE
			----	BEGIN
			----		SELECT 0 as response
			----	END
				
			--SELECT @Form_url=Form_url FROM T0000_DEFAULT_FORM WHERE (Form_Name='ESS Employee Goal Setting' or Form_Name ='KPI Objectives') and Page_Flag='EP' and Is_Active_For_menu = 1
			--Insert Into #TBL_HRMS_LINKS_DASHBOARD(RowNumber,Caption_Text,Caption_URL,IsPopup,Form_ID,Popup_Link_Class,Popup_Class_Id,PopupMethodID)
			--values(25,'KPI Objectives',@Form_url,0,@Forms_ID,'N','N',-1)

			--SET @sch_date_tmp		=''
			--SET @sch_date			= null
			--SET @KPI_month			=null
			--SET @KPI_AlertDay		=null
			--SET @KPI_AlertNoDays	=null
			--SET @KPI_AlertType		=null
			--SET @KPI_month_str		=''
			--SET @KPI_AlertDay_str	=''
			--SET @msg				=0
			
			--SELECT @KPI_Month = KPI_Month,@KPI_AlertDay= KPI_AlertDay,@KPI_AlertNodays=KPI_AlertNodays,@KPI_AlertType=KPI_AlertType
			--	FROM T0040_KPI_AlertSetting WHERE Cmp_Id=@cmp_Id and KPI_Type=2
			
			--SET @KPI_month_str = @KPI_Month
			--SET @KPI_AlertDay_str = @KPI_AlertDay
			
			--SELECT @sch_date_tmp = cast(datepart(YEAR,GETDATE()) as varchar(4)) +'-'+case when  LEN(@KPI_Month) > 1 then @KPI_month_str else '0'+ @KPI_month_str  end+'-'+ case when  LEN(@KPI_AlertDay) > 1 then @KPI_AlertDay_str else '0'+ @KPI_AlertDay_str  end
			--SET @sch_date = DATEADD(DAY,@KPI_AlertNoDays,convert(DATETIME,@sch_date_tmp))
			
			--If @KPI_month = @cur_month 
			--	BEGIN
			--		SET @day_alerttill = @KPI_AlertDay + @KPI_AlertNoDays
			--		If (@cur_day >= @KPI_AlertDay And @cur_day <= @day_alerttill)	
			--			BEGIN
			--				SET @msg =1										
			--			END
			--		ELSE
			--			 SET @msg =0
			--	END
			-- Else If DATEPART(MONTH,@sch_date) = @cur_month 
			--	BEGIN
			--		If @cur_day <= DATEPART(DAY,@sch_date) 
			--			BEGIN
			--				SET @msg =1
			--			END
			--		ELSE
			--			SET @msg =0
			--	END
			--ELSE IF @cur_month > @KPI_Month And @cur_month < DATEPART(MONTH,@sch_date)
			--	BEGIN
			--		SET @msg =1
			--	END
			--ELSE
			--	BEGIN
			--		SET @msg =0
			--	END
			
			--IF @msg = 1
			--BEGIN
			--	Set @Form_url=''
			--	--SELECT 'Prepare Objectives for this Financial year' as response
			--	Insert Into #TBL_HRMS_LINKS_DASHBOARD(RowNumber,Caption_Text,Caption_URL,IsPopup,Form_ID,Popup_Link_Class,Popup_Class_Id,PopupMethodID)
			--	values(26,'Prepare Objectives for this Financial year',@Form_url,0,@Forms_ID,'N','N',-1)
			--END
			----ELSE
			--	--SELECT 0 as response
			----END
			-------------------------------------------------------
			--------------Apprisal_SupNotify-----------------------
			--Set @Message=''

			--SELECT @Message='Apprisal Sup Notify' +CAST(COUNT(KPIPMS_Status) as varchar(5))
			--FROM T0080_KPIPMS_EVAL k LEFT JOIN 
			--T0080_EMP_MASTER AS e ON e.Emp_ID=k.Emp_ID  
			--WHERE k.cmp_id=@cmp_Id  and KPIPMS_Status=2 and e.Emp_Superior=@emp_id
			--Set @Form_url=''
			--Insert Into #TBL_HRMS_LINKS_DASHBOARD(RowNumber,Caption_Text,Caption_URL,IsPopup,Form_ID,Popup_Link_Class,Popup_Class_Id,PopupMethodID)
			--values(27,@Message,@Form_url,0,@Forms_ID,'N','N',-1)

			--DECLARE @int_pref as int =0
			--SELECT @int_pref = isnull(KPI_Preference,0) 
			--FROM T0040_KPI_AlertSetting 
			--WHERE cmp_id=@Cmp_Id and KPI_Type = 4	
			
			--IF @int_pref = 0
			--	BEGIN	
			--		Set @Message=''
			--		Set @Form_url=''

			--		SELECT @Message='Apprisal Sup Notify' +CAST(COUNT(KPIPMS_Status) as varchar(5))
			--		FROM  T0080_KPIPMS_EVAL k left join 
			--			  T0080_EMP_MASTER as e on e.Emp_ID=k.Emp_ID 
			--		WHERE k.cmp_id=@cmp_Id and KPIPMS_Status=3  and e.Emp_Superior=@emp_id

					
			--		Insert Into #TBL_HRMS_LINKS_DASHBOARD(RowNumber,Caption_Text,Caption_URL,IsPopup,Form_ID,Popup_Link_Class,Popup_Class_Id,PopupMethodID)
			--		values(28,@Message,@Form_url,0,@Forms_ID,'N','N',-1)
			--	END
			--ELSE
			--	BEGIN					
			--		EXEC Get_EmpKPI_Level @cmp_Id,@emp_Id,0,' LAD.Status=3' --binal
			--		--need to remianing put logic 
			--	END
			
			--Set @Message=''
			--Set @Form_url=''

			--SELECT @Message='Apprisal Sup Notify' + CAST(COUNT(KPIPMS_Status) as varchar(5))
			--FROM  T0080_KPIPMS_EVAL k left join 
			--	  T0080_EMP_MASTER as e on e.Emp_ID=k.Emp_ID 
			--WHERE k.cmp_id=@cmp_Id and KPIPMS_Status=5  and e.Emp_Superior=@emp_id
				
			--Insert Into #TBL_HRMS_LINKS_DASHBOARD(RowNumber,Caption_Text,Caption_URL,IsPopup,Form_ID,Popup_Link_Class,Popup_Class_Id,PopupMethodID)
			--values(29,@Message,@Form_url,0,@Forms_ID,'N','N',-1)

			--Set @Message=''
			--Set @Form_url=''

			--SELECT @Message='EmpKPI Id ' + CAST(COUNT(EmpKPI_Id) as varchar(5)) --EmpKPI_Id,k.Emp_Id,k.Cmp_Id,Status,FinancialYr,emp_full_name,cat_name,dept_name,desig_name 
			--FROM T0080_EmpKPI AS k left join 
			--t0080_emp_master AS e ON e.emp_id=k.emp_id left join 
			--t0095_increment i ON i.emp_id=e.emp_id INNER join 
			--(
			--	SELECT	max(Increment_ID)Increment_ID,T0095_INCREMENT.Emp_ID
			--	FROM T0095_INCREMENT inner	JOIN
			--	(
			--		SELECT max(Increment_Effective_Date)Increment_Effective_Date,Emp_ID
			--		FROM T0095_INCREMENT
			--		WHERE Cmp_ID = @cmp_Id
			--		GROUP BY Emp_ID
			--	)inc1 ON inc1.Emp_ID = T0095_INCREMENT.Emp_ID
			--	WHERE Cmp_ID =@cmp_Id
			--	GROUP BY T0095_INCREMENT.Emp_ID
			--)inc ON inc.Increment_ID = i.Increment_ID and i.Emp_ID = inc.Emp_ID left JOIN 
			--T0040_DEPARTMENT_MASTER d ON d.Dept_Id=i.Dept_ID left join 
			--T0040_DESIGNATION_MASTER ds ON ds.Desig_ID=i.Desig_Id left join 
			--T0030_CATEGORY_MASTER c ON c.Cat_ID  = i.Cat_ID 
			--WHERE k.Cmp_ID=@cmp_Id  
			--and k.FinancialYr=datepart(year,getdate()) and Status=2 and e.Emp_Superior=@emp_Id
			
			--Insert Into #TBL_HRMS_LINKS_DASHBOARD(RowNumber,Caption_Text,Caption_URL,IsPopup,Form_ID,Popup_Link_Class,Popup_Class_Id,PopupMethodID)
			--values(30,@Message,@Form_url,0,@Forms_ID,'N','N',-1)	
					
			--Set @Message=''
			--Set @Form_url=''

			--		SELECT  @Message='EmpKPI Id ' + CAST(COUNT(EmpKPI_Id) as varchar(5)) --EmpKPI_Id,k.Emp_Id,k.Cmp_Id,Status,FinancialYr,emp_full_name,cat_name,dept_name,desig_name 
			--		FROM T0080_EmpKPI AS k left join 
			--		t0080_emp_master AS e ON e.emp_id=k.emp_id left join 
			--		t0095_increment i ON i.emp_id=e.emp_id INNER join 
			--		(
			--			SELECT	max(Increment_ID)Increment_ID,T0095_INCREMENT.Emp_ID
			--			FROM T0095_INCREMENT inner	JOIN
			--			(
			--				SELECT max(Increment_Effective_Date)Increment_Effective_Date,Emp_ID
			--				FROM T0095_INCREMENT
			--				WHERE Cmp_ID = @cmp_Id
			--				GROUP BY Emp_ID
			--			)inc1 ON inc1.Emp_ID = T0095_INCREMENT.Emp_ID
			--			WHERE Cmp_ID =@cmp_Id
			--			GROUP BY T0095_INCREMENT.Emp_ID
			--		)inc ON inc.Increment_ID = i.Increment_ID and i.Emp_ID = inc.Emp_ID left JOIN 
			--		T0040_DEPARTMENT_MASTER d ON d.Dept_Id=i.Dept_ID left join 
			--		T0040_DESIGNATION_MASTER ds ON ds.Desig_ID=i.Desig_Id left join 
			--		T0030_CATEGORY_MASTER c ON c.Cat_ID  = i.Cat_ID 
			--		WHERE k.Cmp_ID=@cmp_Id  
			--		and k.FinancialYr=datepart(year,getdate()) and Status=3 and e.Emp_Superior=@emp_id			
				
			--Insert Into #TBL_HRMS_LINKS_DASHBOARD(RowNumber,Caption_Text,Caption_URL,IsPopup,Form_ID,Popup_Link_Class,Popup_Class_Id,PopupMethodID)
			--values(31,@Message,@Form_url,0,@Forms_ID,'N','N',-1)	
			
			--Set @Message=''
			--Set @Form_url=''

			--SELECT @Message='EmpKPI Id ' + CAST(COUNT(EmpKPI_Id) as varchar(5))--,EmpKPI_Id,k.Emp_Id,k.Cmp_Id,Status,FinancialYr,emp_full_name,cat_name,dept_name,desig_name 
			--FROM T0080_EmpKPI AS k left join 
			--t0080_emp_master AS e ON e.emp_id=k.emp_id left join 
			--t0095_increment i ON i.emp_id=e.emp_id INNER join 
			--(
			--	SELECT	max(Increment_ID)Increment_ID,T0095_INCREMENT.Emp_ID
			--	FROM T0095_INCREMENT inner	JOIN
			--	(
			--		SELECT max(Increment_Effective_Date)Increment_Effective_Date,Emp_ID
			--		FROM T0095_INCREMENT
			--		WHERE Cmp_ID = @cmp_Id
			--		GROUP BY Emp_ID
			--	)inc1 ON inc1.Emp_ID = T0095_INCREMENT.Emp_ID
			--	WHERE Cmp_ID =@cmp_Id
			--	GROUP BY T0095_INCREMENT.Emp_ID
			--)inc ON inc.Increment_ID = i.Increment_ID and i.Emp_ID = inc.Emp_ID left JOIN 
			--T0040_DEPARTMENT_MASTER d ON d.Dept_Id=i.Dept_ID left join 
			--T0040_DESIGNATION_MASTER ds ON ds.Desig_ID=i.Desig_Id left join 
			--T0030_CATEGORY_MASTER c ON c.Cat_ID  = i.Cat_ID 
			--WHERE k.Cmp_ID=@cmp_Id  
			--and k.FinancialYr=datepart(year,getdate()) and Status=5 and e.Emp_Superior=@emp_Id
			
			--Insert Into #TBL_HRMS_LINKS_DASHBOARD(RowNumber,Caption_Text,Caption_URL,IsPopup,Form_ID,Popup_Link_Class,Popup_Class_Id,PopupMethodID)
			--values(32,@Message,@Form_url,0,@Forms_ID,'N','N',-1)	

			--EXEC Get_KPIPMS_EVAL_Approval_Level @cmp_Id,@emp_Id,0,' LAD.KPIPMS_Status=3' --binal
			
			--IF EXISTS(Select 1 from T0040_KPI_AlertSetting where cmp_id=@cmp_Id and KPI_Type = 4)
			--	BEGIN
			--		Set @Message=''
			--		Set @Form_url=''

			--		SELECT @Message=isnull(KPI_Preference,0) --KPI_Preference 
			--		from T0040_KPI_AlertSetting where cmp_id=@cmp_Id and KPI_Type = 4

			--		Insert Into #TBL_HRMS_LINKS_DASHBOARD(RowNumber,Caption_Text,Caption_URL,IsPopup,Form_ID,Popup_Link_Class,Popup_Class_Id,PopupMethodID)
			--		values(34,@Message,@Form_url,0,@Forms_ID,'N','N',-1)	
			--	END
			----ELSE
			----	BEGIN
			----		SELECT 0 as KPI_Preference
			----	END
			-------------------------------------------------------
			-------------Appraisal_NewObjective--------------------
			--SET @initcount =0
			--SELECT @initcount =count(*) FROM T0040_KPI_AlertSetting WHERE Cmp_Id=@cmp_id and KPI_Type=3
			--IF @initcount >0
			--	BEGIN
			--		SET @KPI_AlertNoDays =0
			--		SELECT @KPI_AlertNoDays = KPI_AlertNodays FROM T0040_KPI_AlertSetting WHERE Cmp_Id=@cmp_id and KPI_Type=3	
					
			--		If EXISTS(SELECT Emp_Full_Name,Date_Of_Join, DATEADD(DAY,- @KPI_AlertNoDays,CONVERT(DATE, getdate())),Emp_Superior 
			--			FROM T0080_EMP_MASTER 
			--			WHERE  Cmp_ID=@cmp_id and Date_Of_Join = DATEADD(DAY,- @KPI_AlertNoDays,CONVERT(DATE, getdate())) 
			--			AND Emp_Superior=@emp_id )--ORDER BY Date_Of_Join DESC
			--			BEGIN
			--				SELECT Emp_Full_Name,Date_Of_Join, DATEADD(DAY,- @KPI_AlertNoDays,CONVERT(DATE, getdate())),Emp_Superior 
			--				FROM T0080_EMP_MASTER 
			--				WHERE  Cmp_ID=@cmp_id and Date_Of_Join = DATEADD(DAY,- @KPI_AlertNoDays,CONVERT(DATE, getdate())) 
			--				AND Emp_Superior=@emp_id
			--				SELECT 'Prepare Reportees Objectives for this Financial year' as response
			--			END
			--		ELSE
			--			BEGIN
			--				SELECT Emp_Full_Name,Date_Of_Join, DATEADD(DAY,- @KPI_AlertNoDays,CONVERT(DATE, getdate())),Emp_Superior 
			--				FROM T0080_EMP_MASTER 
			--				WHERE  Cmp_ID=@cmp_id and Date_Of_Join = DATEADD(DAY,- @KPI_AlertNoDays,CONVERT(DATE, getdate())) 
			--				AND Emp_Superior=@emp_id
			--				SELECT 0 as response
			--			END
						
			--		If EXISTS(SELECT Emp_Full_Name,Date_Of_Join, DATEADD(DAY,-@KPI_AlertNoDays,CONVERT(DATE, getdate())),Emp_Superior 
			--				  FROM T0080_EMP_MASTER 
			--				  WHERE  Cmp_ID=@cmp_id and Date_Of_Join = DATEADD(DAY,-@KPI_AlertNoDays,CONVERT(DATE, getdate())) and Emp_Id=@Emp_Id )--ORDER BY Date_Of_Join DESC
			--			BEGIN
			--				SELECT 'Prepare Objectives for this Financial year.' as response
			--			END
			--		ELSE
			--			BEGIN
			--				SELECT 0 as response
			--			END
			--	END	
			--ELSE
			--	BEGIN
			--		SELECT Emp_Full_Name,Date_Of_Join, DATEADD(DAY,- @KPI_AlertNoDays,CONVERT(DATE, getdate())),Emp_Superior 
			--		FROM T0080_EMP_MASTER 
			--		WHERE  Cmp_ID=@cmp_id and Date_Of_Join = DATEADD(DAY,- @KPI_AlertNoDays,CONVERT(DATE, getdate())) 
			--		AND Emp_Superior=@emp_id
			--		SELECT 0 as response
			--		SELECT 0 as response
			--	END
			-------------------------------------------------------
			-------------Appraisal_NotifyEmployee------------------
			--SELECT * FROM T0080_KPIPMS_EVAL WHERE Cmp_ID=@cmp_id  and KPIPMS_FinancialYr= DATEPART(YYYY,GETDATE()) and  KPIPMS_Status=1 and emp_id=@emp_id 
			--SELECT EmpKPI_Id,k.Emp_Id,k.Cmp_Id,[Status],FinancialYr,emp_full_name,cat_name,dept_name,desig_name 
			--FROM T0080_EmpKPI AS k LEFT JOIN t0080_emp_master AS e ON e.emp_id=k.emp_id LEFT JOIN 
			--	 T0095_INCREMENT i ON i.emp_id=e.emp_id INNER JOIN 
			--	 (
			--		SELECT MAX(Increment_ID)Increment_ID,T0095_INCREMENT.Emp_ID
			--		FROM  T0095_INCREMENT INNER	JOIN
			--			  (
			--					SELECT MAX(Increment_Effective_Date)Increment_Effective_Date,T0095_INCREMENT.Emp_ID
			--					FROM  T0095_INCREMENT
			--					WHERE Cmp_ID=@cmp_id
			--					GROUP by Emp_ID
			--			  )inc1 ON inc1.Emp_ID = T0095_INCREMENT.Emp_ID
			--		WHERE Cmp_ID=@cmp_id
			--		GROUP by T0095_INCREMENT.Emp_ID
			--	 )inc ON inc.Increment_ID = i.Increment_ID and inc.Emp_ID = i.Emp_ID LEFT JOIN  
			--	 T0040_DEPARTMENT_MASTER d ON d.Dept_Id=i.Dept_ID LEFT JOIN 
			--	 T0040_DESIGNATION_MASTER ds ON ds.Desig_ID=i.Desig_Id LEFT JOIN 
			--	 T0030_CATEGORY_MASTER c ON c.Cat_ID  = i.Cat_ID 
			--where k.Cmp_ID=@Cmp_Id AND k.Emp_Id=@emp_id AND Financialyr=DATEPART(YYYY,GETDATE()) AND Status=1 
			-------------------------------------------------------
			------------Appraisal_BSC_Alert------------------------
			--SELECT * FROM T0052_BSC_AlertSetting WHERE BSC_AlertType =1 and Cmp_Id = @cmp_id
						
			--SET @sch_date_tmp		=''
			--SET @sch_date			= null
			--SET @KPI_month			=null
			--SET @KPI_AlertDay		=null
			--SET @KPI_AlertNoDays	=null
			--SET @KPI_AlertType		=null
			--SET @KPI_month_str		=''
			--SET @KPI_AlertDay_str	=''
			--SET @msg				=0
			
			--SELECT @KPI_Month = BSC_Month,@KPI_AlertDay= BSC_AlertDay,@KPI_AlertNodays=BSC_AlertNodays,@KPI_AlertType=BSC_AlertType
			--	FROM T0052_BSC_AlertSetting WHERE Cmp_Id=@cmp_Id and BSC_AlertType=2
			
			--SET @KPI_month_str = @KPI_Month
			--SET @KPI_AlertDay_str = @KPI_AlertDay
			
			--SELECT @sch_date_tmp = cast(datepart(YEAR,GETDATE()) as varchar(4)) +'-'+case when  LEN(@KPI_Month) > 1 then @KPI_month_str else '0'+ @KPI_month_str  end+'-'+ case when  LEN(@KPI_AlertDay) > 1 then @KPI_AlertDay_str else '0'+ @KPI_AlertDay_str  end
			--SET @sch_date = DATEADD(DAY,@KPI_AlertNoDays,convert(DATETIME,@sch_date_tmp))
			
			--IF @KPI_month = @cur_month
			--	BEGIN
			--		SET @day_alerttill = @KPI_AlertDay + @KPI_AlertNoDays
			--		If (@cur_day >= @KPI_AlertDay And @cur_day <= @day_alerttill)	
			--			BEGIN
			--				SET @msg =1										
			--			END
			--		ELSE
			--			 SET @msg =0
			--	END
			--ELSE IF DATEPART(MONTH,@sch_date) = @cur_month 
			--	BEGIN
			--		SET @msg =1		
			--	END
			--ELSE IF (@cur_month > @KPI_month And @cur_month < DATEPART(MONTH,@sch_date))
			--	BEGIN
			--		SET @msg =1			
			--	END
			--ELSE
			--	BEGIN
			--		SET @msg =0
			--	END
			
			--IF @msg = 1				
			--	SELECT 'Start the '+ CASE WHEN isnull(@KPI_AlertType,1) = 1 THEN 'Interim' ELSE 'Final' END +' Balance Score Card Assessment' as response
			--ELSE
			--	SELECT 0 as response	
			-------------------------------------------------------
			----------------------DPT_Alert------------------------
			--SELECT emp_id,StartDate,Enddate,DPT_Status 
			--FROM T0090_DevelopmentPlanningTemplate 
			--WHERE Cmp_ID=@cmp_id AND CONVERT(varchar(12),GETDATE(),105) >= CONVERT(varchar(12),StartDate,105) 
			--AND CONVERT(varchar(12),GETDATE(),105) <= CONVERT(varchar(12),Enddate,105) AND DPT_Status = 0 and emp_id= @emp_Id
			
			--SELECT emp_id,StartDate,Enddate,PIP_Status 
			--FROM T0090_PerformanceImprovementPlan 
			--WHERE Cmp_ID=@cmp_id AND CONVERT(varchar(12),getdate(),105) >= CONVERT(varchar(12),StartDate,105) 
			--	  AND CONVERT(varchar(12),GETDATE(),105) <= CONVERT(varchar(12),Enddate,105) AND PIP_Status = 0 
			--	  AND emp_id= @emp_Id
			-------------------------------------------------------

			----end extra added 24102019

				update #TBL_HRMS_LINKS_DASHBOARD
				Set Caption_URL=''
				where Caption_URL is null


				Select * from #TBL_HRMS_LINKS_DASHBOARD order by Caption_Text asc

			--	Select * from @AllPrivilages

				DROP TABLE #TBL_HRMS_LINKS_DASHBOARD


END
