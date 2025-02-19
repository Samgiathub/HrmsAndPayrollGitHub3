

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[P_HRMS_HOME_DASHBOARD_NOTIFICATIONS_Old_count]
	@Cmp_ID Int,  
    @Branch_ID Int  ,
    @Emp_id Int  ,
	@Privilege_Id Int
AS

        SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON

BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.

    	create table #TBL_HRMS_LINKS_DASHBOARD
		(  
			
			LinkText varchar(250),  
			LinkURL varchar(800),  
			IsAlert bit,
			IsPopup bit
			 
		)  
			


			----------------Self Assessment Form Team Table(0) -------------
			--(Team)
				IF EXISTS(
							SELECT ERD.Emp_ID ,I.InitiateId
							FROM  T0050_HRMS_InitiateAppraisal I WITH (NOLOCK) INNER JOIN
							T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK) on ERD.Emp_ID = i.Emp_Id
							 INNER JOIN 
							(
								SELECT MAX(Row_ID)Row_ID,T0090_EMP_REPORTING_DETAIL.Emp_ID from
								T0090_EMP_REPORTING_DETAIL WITH (NOLOCK) inner JOIN
								(
									SELECT max(Effect_Date)Effect_Date,Emp_ID
									FROM T0090_EMP_REPORTING_DETAIL WITH (NOLOCK) 
									Where Effect_Date<= GETDATE()
									GROUP by Emp_ID
								)ERD1 on ERD1.Emp_ID = T0090_EMP_REPORTING_DETAIL.Emp_ID
								GROUP by T0090_EMP_REPORTING_DETAIL.Emp_ID
							)ERD2 on ERD2.Row_ID = erd.Row_ID and ERD2.Emp_ID = ERD.Emp_ID
							where ERD.R_Emp_ID = @emp_id and SA_Status<>1 and 
							 SA_Startdate <= CONVERT(varchar(10),GETDATE(),120) and SA_Enddate >= CONVERT(varchar(10),GETDATE(),120)and SA_SendToRM=1
							
						)
					BEGIN
						Insert Into #TBL_HRMS_LINKS_DASHBOARD(LinkText,LinkURL,IsAlert,IsPopup)
						SELECT 'Self Assessment Form',CASE WHEN isnull(Form_url,'SelfAppraisal_Form.aspx')<>'' THEN Form_url  ELSE 'SelfAppraisal_Form.aspx' END Form_url,0,0
						FROM T0000_DEFAULT_FORM WITH (NOLOCK)
						WHERE Form_Name='TD_Home_ESS_294'	
					END
			---------------- end Self Assessment Form Team-------------

			--(self)

			---------------- Self Assessment Form self Table(1) -------------
				IF EXISTS(SELECT InitiateId,Cmp_ID,Emp_Id,AppraiserId,SA_Startdate,SA_Enddate 
					  FROM T0050_HRMS_InitiateAppraisal WITH (NOLOCK)
					  WHERE Emp_Id = @emp_id AND   
							SA_Startdate <= CONVERT(varchar(10),GETDATE(),120) and (SA_Enddate >= CONVERT(varchar(10),GETDATE(),120) 
							and SA_Status in(3,4)) and SA_SendToRM <> 1)
				BEGIN				
					DECLARE @init_Id NUMERIC(18,0)
					SELECT @init_Id =InitiateId--,Cmp_ID,Emp_Id,AppraiserId,SA_Startdate,SA_Enddate 
					FROM  T0050_HRMS_InitiateAppraisal WITH (NOLOCK) inner JOIN
							(
								SELECT (case when SA_Status =2 then 1 when SA_Status = 1 then 0
								when (SA_Status= 4 or SA_Status = 0 or SA_Status = 3) then case when SA_Enddate>= '2017-03-31' then 1 else 0  end  else 0 end) show,InitiateId as initid
								from T0050_HRMS_InitiateAppraisal WITH (NOLOCK)
								where Emp_Id = @emp_id
								and   SA_Startdate <= CONVERT(varchar(10),GETDATE(),120)
							)t on t.initid = T0050_HRMS_InitiateAppraisal.InitiateId
					WHERE Emp_Id = @emp_id AND   
						  SA_Startdate <= CONVERT(varchar(10),GETDATE(),120) and t.show = 1 --and ( SA_Enddate >= CONVERT(varchar(10),GETDATE(),120) and SA_Status<>1) and SA_SendToRM <> 1
							--print @init_Id	
					Insert Into #TBL_HRMS_LINKS_DASHBOARD(LinkText,LinkURL,IsAlert,IsPopup)
					SELECT 'Self Assessment Form',CASE WHEN isnull(Form_url,'SelfAppraisal_Form.aspx')<>'' THEN Form_url +'?Initid=' + cast(@init_Id AS VARCHAR) ELSE 'SelfAppraisal_Form.aspx?Initid=' + cast(@init_Id AS VARCHAR) END Form_url,0,0
					FROM T0000_DEFAULT_FORM WITH (NOLOCK) 
					WHERE Form_Name='TD_Home_ESS_294'		
				END
				---------------- end Self Assessment Form self-------------


				DECLARE @KPA_Default as INT
				set @KPA_Default = 0
				Select top 1 @KPA_Default=KPA_Default from T0050_AppraisalLimit_Setting WITH (NOLOCK) where cmp_id=@Cmp_ID ORDER by Limit_Id desc

				-------------SelfAssessmentForm_Pending Table(2)------------

				DECLARE @initcount INT = 0
				SELECT @initcount = COUNT(i.InitiateId) 
				FROM  T0050_HRMS_InitiateAppraisal I WITH (NOLOCK) INNER JOIN
				T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK) on ERD.Emp_ID = i.Emp_Id
				 INNER JOIN 
				(
					SELECT MAX(Row_ID)Row_ID,T0090_EMP_REPORTING_DETAIL.Emp_ID FROM
					T0090_EMP_REPORTING_DETAIL WITH (NOLOCK) INNER JOIN
					(
						SELECT MAX(Effect_Date)Effect_Date,T0090_EMP_REPORTING_DETAIL.Emp_ID
						FROM T0090_EMP_REPORTING_DETAIL WITH (NOLOCK) INNER JOIN
							 T0050_HRMS_InitiateAppraisal IA WITH (NOLOCK) ON IA.Emp_Id = T0090_EMP_REPORTING_DETAIL.Emp_ID
						WHERE Effect_Date<= IA.SA_Startdate AND ((SA_Status=0) or (SA_Status=1 and Overall_Status=8) or (SA_Status=1 and Overall_Status=9))
						GROUP by T0090_EMP_REPORTING_DETAIL.Emp_ID
					)ERD1 ON ERD1.Emp_ID = T0090_EMP_REPORTING_DETAIL.Emp_ID
					GROUP BY T0090_EMP_REPORTING_DETAIL.Emp_ID
				)ERD2 ON ERD2.Row_ID = erd.Row_ID AND ERD2.Emp_ID = ERD.Emp_ID
				WHERE ERD.R_Emp_ID = @emp_id AND ((SA_Status=0) or (I.SA_Status=1 and I.Overall_Status=8) or (I.SA_Status=1 and I.Overall_Status=9))
					AND DATEPART(YYYY,SA_Startdate) =DATEPART(YYYY,GETDATE())
				
			
				Insert Into #TBL_HRMS_LINKS_DASHBOARD(LinkText,LinkURL,IsAlert,IsPopup)
				SELECT  'Employee/s For ' + (SELECT [Alias]
							FROM [ORANGE_HRMS].[dbo].[T0040_CAPTION_SETTING]
							 where Caption='Reporting Manager' and Cmp_Id=@Cmp_ID) + ' Approval (' + cast(@initcount as varchar(10))+ ')',
					--@initcount as InitiateId,
					CASE WHEN isnull(Form_url,'Ess_EmpAssessment.aspx') <> '' THEN Form_url 
					WHEN @KPA_Default=1 THEN 'Ess_EmpAssessment.aspx' ELSE 'Ess_PerformanceAssessment.aspx' END Form_url,0,0
				FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_Name='TD_Home_ESS_295'	
				----------------------------------------------------

				-------------end SelfAssessmentForm_Pending------------


				---------------AppraisalFinalization() HOD/GH Table(3),Table(4) -------

				DECLARE @Alpha_Emp_Code varchar(50) 
				SELECT	@Alpha_Emp_Code =Alpha_Emp_Code FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE Emp_ID = @emp_id
				SET @initcount  =0 
			
				SELECT @initcount = COUNT(InitiateId) 
				FROM V0050_HRMS_InitiateAppraisal 
				WHERE  DATEPART(YYYY,SA_Startdate) = DATEPART(YYYY,GETDATE()) AND 
				(Overall_Status=11 or Overall_Status =(CASE WHEN (ISNULL(SendToHOD,0) =1 and Overall_Status =0) THEN null WHEN (isnull(SendToHOD,0) = 0 and Overall_Status=0) THEN Overall_Status WHEN (isnull(SendToHOD,0) = 1 and Overall_Status=7) THEN Overall_Status END))  
				AND GH_Id = @emp_id
				
				IF @initcount <> 0
				BEGIN
					Insert Into #TBL_HRMS_LINKS_DASHBOARD(LinkText,LinkURL,IsAlert,IsPopup)
					SELECT 
						'Employee/s For ' + (SELECT [Alias]
							FROM [ORANGE_HRMS].[dbo].[T0040_CAPTION_SETTING]
							 where Caption='Group Head/GH' and Cmp_Id=@Cmp_ID) + ' Approval (' + cast(@initcount as varchar(10))+ ')',
						--@initcount AS InitiateId ,
						CASE WHEN isnull(Form_url,'Ess_AppraisalFinalization.aspx')<>'' THEN Form_url  ELSE 'Ess_AppraisalFinalization.aspx' END Form_url,0,0
					FROM T0000_DEFAULT_FORM WITH (NOLOCK)
					WHERE Form_Name='TD_Home_ESS_296'	
				END
				SELECT @initcount =count(DISTINCT InitiateId) --AS InitiateId 
				FROM V0050_HRMS_InitiateAppraisal V INNER JOIN
					 T0095_INCREMENT inc WITH (NOLOCK) on inc.Emp_ID = v.Emp_Id INNER JOIN
					 (
						SELECT max(Increment_ID)Increment_ID,T0095_INCREMENT.Emp_ID
						FROM T0095_INCREMENT WITH (NOLOCK) INNER JOIN
						(
							SELECT max(Increment_Effective_Date)Increment_Effective_Date,T0095_INCREMENT.Emp_ID
							FROM T0095_INCREMENT WITH (NOLOCK) INNER JOIN
								 T0050_HRMS_InitiateAppraisal I WITH (NOLOCK) on i.Emp_Id = T0095_INCREMENT.Emp_ID
							WHERE T0095_INCREMENT.Cmp_ID =@Cmp_ID and Increment_Effective_Date <= I.SA_Startdate
							GROUP by T0095_INCREMENT.Emp_ID
						)inc1 ON inc1.Emp_ID = T0095_INCREMENT.Emp_ID
						WHERE Cmp_ID = @Cmp_ID
						GROUP BY T0095_INCREMENT.Emp_ID
					 )inc2 ON inc2.Increment_ID = inc.Increment_ID and inc2.Emp_ID = inc.Emp_ID LEFT JOIN
					 T0095_Department_Manager DM WITH (NOLOCK) on DM.Dept_Id = inc.Dept_ID LEFT JOIN
					 (
						SELECT max(Effective_Date)Effective_Date,Dept_Id
						FROM T0095_Department_Manager WITH (NOLOCK)	
						WHERE Cmp_id = @Cmp_ID
						GROUP BY Dept_Id
					 )DM1 ON DM1.Dept_Id = DM.Dept_Id
				WHERE DATEPART(YYYY,SA_Startdate) = DATEPART(YYYY,GETDATE()) and 
				(V.Overall_Status=2 or V.Overall_Status=10 or Overall_Status =(CASE WHEN SendToHOD =1 and Overall_Status =0 THEN Overall_Status when SendToHOD =0 and Overall_Status is not null then null else null end)) 
				and SendToHOD =1 and @emp_id = (CASE WHEN isnull(v.hod_id,0) <> 0  THEN v.hod_id ELSE dm.Emp_id END)
				IF @initcount <> 0
				BEGIN
					Insert Into #TBL_HRMS_LINKS_DASHBOARD(LinkText,LinkURL,IsAlert,IsPopup)
					SELECT 
						'Employee/s For ' + (SELECT [Alias]
							FROM [ORANGE_HRMS].[dbo].[T0040_CAPTION_SETTING]
							 where Caption='HOD' and Cmp_Id=@Cmp_ID) + ' Approval (' + cast(@initcount as varchar(10))+ ')',
						--@initcount AS InitiateId ,
						--@initcount AS InitiateId ,
						CASE WHEN isnull(Form_url,'Ess_ApprisalHODApproval.aspx')<>'' THEN Form_url  ELSE 'Ess_ApprisalHODApproval.aspx' END Form_url,0,0
					FROM T0000_DEFAULT_FORM WITH (NOLOCK)
					WHERE Form_Name='TD_Home_ESS_350'	
				END
				---------------end AppraisalFinalization() HOD/GH-------



				---------------Apprisal_Alert Table(5)-----------------
				DECLARE @sch_date_tmp varchar(10)
				DECLARE @sch_date datetime


				DECLARE @KPI_month		int
				DECLARE @KPI_AlertDay  int
				DECLARE @KPI_AlertNoDays  int
				DECLARE @KPI_AlertType  int

				DECLARE @KPI_month_str		varchar(3)
				DECLARE @KPI_AlertDay_str  varchar(3)

				DECLARE @cur_month  Integer
				DECLARE @cur_day  Integer
				DECLARE @day_alerttill  Integer

				SET @cur_month = DATEPART(month,GETDATE())
				SET @cur_day = DATEPART(DAY,GETDATE())
			
				declare @msg as int 
				SET @msg = 0
			
				DECLARE cur CURSOR
				FOR	
					SELECT KPI_Month,KPI_AlertDay,KPI_AlertNodays,KPI_AlertType
					FROM T0040_KPI_AlertSetting WITH (NOLOCK) WHERE Cmp_Id=@cmp_Id and KPI_Type=1 
				OPEN cur
					FETCH NEXT FROM cur INTO @KPI_Month,@KPI_AlertDay,@KPI_AlertNodays,@KPI_AlertType
					WHILE @@fetch_status = 0
						BEGIN
							SET @KPI_month_str = @KPI_Month
							SET @KPI_AlertDay_str = @KPI_AlertDay
						
							SELECT @sch_date_tmp = cast(datepart(YEAR,GETDATE()) as varchar(4)) +'-'+case when  LEN(@KPI_Month) > 1 then @KPI_month_str else '0'+ @KPI_month_str  end+'-'+ case when  LEN(@KPI_AlertDay) > 1 then @KPI_AlertDay_str else '0'+ @KPI_AlertDay_str  end
						
							if len(@KPI_AlertDay) > 1 
								SET @sch_date = DATEADD(DAY,@KPI_AlertNoDays,convert(DATETIME,@sch_date_tmp))
					
						
							IF @cur_month = @KPI_month 
								BEGIN
									SET @day_alerttill =@KPI_AlertDay + @KPI_AlertNoDays
									IF @cur_day >= @KPI_AlertDay And @cur_day <= @day_alerttill
										BEGIN
											set @msg =1
											BREAK;
										END	
									ELSE
										BEGIN
											set @msg =0
										END				
								END	
							ELSE IF @cur_month = DATEPART(MONTH,@sch_date)
								BEGIN
									IF @cur_day <= DATEPART(DAY,@sch_date)
										BEGIN
											SET @msg =1
											BREAK;
										END	
									ELSE
										BEGIN
											SET @msg = 0
										END					
								END	
							ELSE If @cur_month > @KPI_month And @cur_month < DATEPART(MONTH,@sch_date)
								BEGIN
									SET @msg =1
									BREAK;							
								END
							ELSE
								BEGIN
									SET @msg = 0
								END	
							
							FETCH NEXT FROM cur INTO @KPI_Month,@KPI_AlertDay,@KPI_AlertNodays,@KPI_AlertType
						END				
				CLOSE cur
				DEALLOCATE cur
			
				IF @msg  = 1
					BEGIN
						Insert Into #TBL_HRMS_LINKS_DASHBOARD(LinkText,LinkURL,IsAlert,IsPopup)
						SELECT 'Start the ' + case when @KPI_AlertType =1 then 'Interim' else 'Final' end + ' Appraisal process' as response,
							CASE WHEN isnull(Form_url,'Ess_KPI_PMS_AppraisalForm.aspx')<>'' THEN Form_url  ELSE 'Ess_KPI_PMS_AppraisalForm.aspx' END Form_url,1,0
						FROM T0000_DEFAULT_FORM WITH (NOLOCK) 
						WHERE (Form_Name='ESS Employee Goal Assessment' or Form_Name ='KPI Apparisal Form') and page_Flag= 'EP' and Is_Active_For_menu = 1
					END
			
			---------------End Apprisal_Alert-----------------



			------------Appraisal Notify Table(6) Table(7) Table(8) to  Table(15)-------------------------

			DECLARE @KPIPMS_Status  INT = 0
			SELECT  @KPIPMS_Status = isnull(KPIPMS_Status,0) 
			FROM    T0080_KPIPMS_EVAL WITH (NOLOCK)
			WHERE   cmp_id=@cmp_id and emp_id= @emp_id  and kpipms_status=1
			If @KPIPMS_Status =1
				BEGIN
					Insert Into #TBL_HRMS_LINKS_DASHBOARD(LinkText,LinkURL,IsAlert,IsPopup)
					SELECT 'Approve your KPI rating' as response,'Ess_KPI_PMS_AppraisalForm.aspx' as Url,0,0
				END
			
				
			--SELECT Form_url FROM T0000_DEFAULT_FORM WHERE (Form_Name='ESS Employee Goal Setting' or Form_Name ='KPI Objectives') and Page_Flag='EP' and Is_Active_For_menu = 1
			
			SET @sch_date_tmp		=''
			SET @sch_date			= null
			SET @KPI_month			=null
			SET @KPI_AlertDay		=null
			SET @KPI_AlertNoDays	=null
			SET @KPI_AlertType		=null
			SET @KPI_month_str		=''
			SET @KPI_AlertDay_str	=''
			SET @msg				=0
			
			SELECT @KPI_Month = KPI_Month,@KPI_AlertDay= KPI_AlertDay,@KPI_AlertNodays=KPI_AlertNodays,@KPI_AlertType=KPI_AlertType
				FROM T0040_KPI_AlertSetting WITH (NOLOCK) WHERE Cmp_Id=@cmp_Id and KPI_Type=2
			
			SET @KPI_month_str = @KPI_Month
			SET @KPI_AlertDay_str = @KPI_AlertDay
			
			SELECT @sch_date_tmp = cast(datepart(YEAR,GETDATE()) as varchar(4)) +'-'+case when  LEN(@KPI_Month) > 1 then @KPI_month_str else '0'+ @KPI_month_str  end+'-'+ case when  LEN(@KPI_AlertDay) > 1 then @KPI_AlertDay_str else '0'+ @KPI_AlertDay_str  end
			SET @sch_date = DATEADD(DAY,@KPI_AlertNoDays,convert(DATETIME,@sch_date_tmp))
			
			If @KPI_month = @cur_month 
				BEGIN
					SET @day_alerttill = @KPI_AlertDay + @KPI_AlertNoDays
					If (@cur_day >= @KPI_AlertDay And @cur_day <= @day_alerttill)	
						BEGIN
							SET @msg =1										
						END
					ELSE
						 SET @msg =0
				END
			 Else If DATEPART(MONTH,@sch_date) = @cur_month 
				BEGIN
					If @cur_day <= DATEPART(DAY,@sch_date) 
						BEGIN
							SET @msg =1
						END
					ELSE
						SET @msg =0
				END
			ELSE IF @cur_month > @KPI_Month And @cur_month < DATEPART(MONTH,@sch_date)
				BEGIN
					SET @msg =1
				END
			ELSE
				BEGIN
					SET @msg =0
				END
			
			IF @msg = 1
			Begin
				--need to put  insert query here binal remaining
				--SELECT 'Prepare Objectives for this Financial year' as response
				Insert Into #TBL_HRMS_LINKS_DASHBOARD(LinkText,LinkURL,IsAlert,IsPopup)
				SELECT 'Prepare Objectives for this Financial year', Form_url ,0,0 FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE (Form_Name='ESS Employee Goal Setting' or Form_Name ='KPI Objectives') and Page_Flag='EP' and Is_Active_For_menu = 1
			End
			
			-------------------------------------------------

			------------End Appraisal Notify-------------------------

			--need to change here remaing binal for insert data in table
			------------Apprisal_SupNotify  Table(9)-----------------------
			Insert Into #TBL_HRMS_LINKS_DASHBOARD(LinkText,LinkURL,IsAlert,IsPopup)
			SELECT 
					 (SELECT [Alias]
							FROM [ORANGE_HRMS].[dbo].[T0040_CAPTION_SETTING]
							 where Caption='KPA' and Cmp_Id=@Cmp_ID) + ' Reviewed by Employee (' + cast(COUNT(KPIPMS_Status) as varchar(10))+ ')'
						,'Ess_Sup_KPIPMS_AppraisalForm.aspx?st=2',0,0
				--COUNT(KPIPMS_Status) AS cnt  
				
			FROM T0080_KPIPMS_EVAL k WITH (NOLOCK) LEFT JOIN 
			T0080_EMP_MASTER AS e WITH (NOLOCK) ON e.Emp_ID=k.Emp_ID  
			WHERE k.cmp_id=@cmp_Id  and KPIPMS_Status=2 and e.Emp_Superior=@emp_id  
			having  COUNT(KPIPMS_Status) >0 
			
			DECLARE @int_pref as int =0
			SELECT @int_pref = isnull(KPI_Preference,0) 
			FROM T0040_KPI_AlertSetting WITH (NOLOCK)
			WHERE cmp_id=@Cmp_Id and KPI_Type = 4	
			
			IF @int_pref = 0
				BEGIN	
					Insert Into #TBL_HRMS_LINKS_DASHBOARD(LinkText,LinkURL,IsAlert,IsPopup)
					SELECT 
							(SELECT [Alias]
								FROM [ORANGE_HRMS].[dbo].[T0040_CAPTION_SETTING]
								 where Caption='KPA' and Cmp_Id=@Cmp_ID) + ' Reviewed by Employee (' + cast(COUNT(KPIPMS_Status) as varchar(10))+ ')'
							,'Ess_Sup_KPIPMS_AppraisalForm.aspx?st=3',0,0
						--COUNT(KPIPMS_Status)  as cnt 
					FROM  T0080_KPIPMS_EVAL k WITH (NOLOCK) left join 
							  T0080_EMP_MASTER as e WITH (NOLOCK) on e.Emp_ID=k.Emp_ID 
					WHERE k.cmp_id=@cmp_Id and KPIPMS_Status=3  and e.Emp_Superior=@emp_id 
					having  COUNT(KPIPMS_Status) >0 
				END
			ELSE
				BEGIN					
					EXEC Get_EmpKPI_Level @cmp_Id,@emp_Id,0,' LAD.Status=3'
				END


				Insert Into #TBL_HRMS_LINKS_DASHBOARD(LinkText,LinkURL,IsAlert,IsPopup)
				SELECT 
						(SELECT [Alias]
								FROM [ORANGE_HRMS].[dbo].[T0040_CAPTION_SETTING]
								 where Caption='KPA' and Cmp_Id=@Cmp_ID) + ' For Review (' + cast(COUNT(KPIPMS_Status) as varchar(10))+ ')'
							,'Ess_Sup_KPIPMS_AppraisalForm.aspx?st=5',0,0
					--COUNT(KPIPMS_Status)  as cnt 
				FROM  T0080_KPIPMS_EVAL k WITH (NOLOCK)left join 
					  T0080_EMP_MASTER as e WITH (NOLOCK) on e.Emp_ID=k.Emp_ID 
				WHERE k.cmp_id=@cmp_Id and KPIPMS_Status=5  and e.Emp_Superior=@emp_id 
				having  COUNT(KPIPMS_Status) >0 
				
			Insert Into #TBL_HRMS_LINKS_DASHBOARD(LinkText,LinkURL,IsAlert,IsPopup)
			SELECT	
				(SELECT [Alias]
							FROM [ORANGE_HRMS].[dbo].[T0040_CAPTION_SETTING]
							 where Caption='KPA' and Cmp_Id=@Cmp_ID) + ' For Review (' + cast(COUNT(EmpKPI_Id) as varchar(10))+ ')'
						,'Ess_Sup_KPIPMS_AppraisalForm.aspx?st=2',0,0
				--COUNT(EmpKPI_Id)EmpKPI_Id
			FROM T0080_EmpKPI AS k WITH (NOLOCK) left join 
			t0080_emp_master AS e WITH (NOLOCK) ON e.emp_id=k.emp_id left join 
			t0095_increment i WITH (NOLOCK) ON i.emp_id=e.emp_id INNER join 
			(
				SELECT	max(Increment_ID)Increment_ID,T0095_INCREMENT.Emp_ID
				FROM T0095_INCREMENT WITH (NOLOCK) inner	JOIN
				(
					SELECT max(Increment_Effective_Date)Increment_Effective_Date,Emp_ID
					FROM T0095_INCREMENT WITH (NOLOCK)
					WHERE Cmp_ID = @cmp_Id
					GROUP BY Emp_ID
				)inc1 ON inc1.Emp_ID = T0095_INCREMENT.Emp_ID
				WHERE Cmp_ID =@cmp_Id
				GROUP BY T0095_INCREMENT.Emp_ID
			)inc ON inc.Increment_ID = i.Increment_ID and i.Emp_ID = inc.Emp_ID left JOIN 
			T0040_DEPARTMENT_MASTER d WITH (NOLOCK) ON d.Dept_Id=i.Dept_ID left join 
			T0040_DESIGNATION_MASTER ds WITH (NOLOCK) ON ds.Desig_ID=i.Desig_Id left join 
			T0030_CATEGORY_MASTER c WITH (NOLOCK) ON c.Cat_ID  = i.Cat_ID 
			WHERE k.Cmp_ID=@cmp_Id  
			and k.FinancialYr=datepart(year,getdate()) and Status=2 and e.Emp_Superior=@emp_Id 
			having COUNT(EmpKPI_Id) > 0
			
				
			Insert Into #TBL_HRMS_LINKS_DASHBOARD(LinkText,LinkURL,IsAlert,IsPopup)	
			SELECT
				(SELECT [Alias]
							FROM [ORANGE_HRMS].[dbo].[T0040_CAPTION_SETTING]
							 where Caption='KPA' and Cmp_Id=@Cmp_ID) + ' For Review (' + cast(COUNT(EmpKPI_Id) as varchar(10))+ ')'
						,'Ess_Sup_KPIPMS_AppraisalForm.aspx?st=3',0,0
				-- COUNT(EmpKPI_Id)EmpKPI_Id
				FROM T0080_EmpKPI AS k WITH (NOLOCK) left join 
					t0080_emp_master AS e WITH (NOLOCK) ON e.emp_id=k.emp_id left join 
					t0095_increment i WITH (NOLOCK) ON i.emp_id=e.emp_id INNER join 
					(
						SELECT	max(Increment_ID)Increment_ID,T0095_INCREMENT.Emp_ID
						FROM T0095_INCREMENT WITH (NOLOCK) inner	JOIN
						(
							SELECT max(Increment_Effective_Date)Increment_Effective_Date,Emp_ID
							FROM T0095_INCREMENT WITH (NOLOCK)
							WHERE Cmp_ID = @cmp_Id
							GROUP BY Emp_ID
						)inc1 ON inc1.Emp_ID = T0095_INCREMENT.Emp_ID
						WHERE Cmp_ID =@cmp_Id
						GROUP BY T0095_INCREMENT.Emp_ID
					)inc ON inc.Increment_ID = i.Increment_ID and i.Emp_ID = inc.Emp_ID left JOIN 
					T0040_DEPARTMENT_MASTER d WITH (NOLOCK) ON d.Dept_Id=i.Dept_ID left join 
					T0040_DESIGNATION_MASTER ds WITH (NOLOCK) ON ds.Desig_ID=i.Desig_Id left join 
					T0030_CATEGORY_MASTER c WITH (NOLOCK) ON c.Cat_ID  = i.Cat_ID 
				WHERE k.Cmp_ID=@cmp_Id  
					and k.FinancialYr=datepart(year,getdate()) and Status=3 and e.Emp_Superior=@emp_id	 
					having COUNT(EmpKPI_Id) > 0		
				
			
			Insert Into #TBL_HRMS_LINKS_DASHBOARD(LinkText,LinkURL,IsAlert,IsPopup)
			SELECT 
				(SELECT [Alias]
							FROM [ORANGE_HRMS].[dbo].[T0040_CAPTION_SETTING]
							 where Caption='KPA' and Cmp_Id=@Cmp_ID) + ' For Review (' + cast(COUNT(EmpKPI_Id) as varchar(10))+ ')'
						,'Ess_Sup_KPIPMS_AppraisalForm.aspx?st=5',0,0
				--COUNT(EmpKPI_Id)EmpKPI_Id
			FROM T0080_EmpKPI AS k WITH (NOLOCK)left join 
			t0080_emp_master AS e WITH (NOLOCK) ON e.emp_id=k.emp_id left join 
			t0095_increment i WITH (NOLOCK) ON i.emp_id=e.emp_id INNER join 
			(
				SELECT	max(Increment_ID)Increment_ID,T0095_INCREMENT.Emp_ID
				FROM T0095_INCREMENT WITH (NOLOCK)inner	JOIN
				(
					SELECT max(Increment_Effective_Date)Increment_Effective_Date,Emp_ID
					FROM T0095_INCREMENT WITH (NOLOCK)
					WHERE Cmp_ID = @cmp_Id
					GROUP BY Emp_ID
				)inc1 ON inc1.Emp_ID = T0095_INCREMENT.Emp_ID
				WHERE Cmp_ID =@cmp_Id
				GROUP BY T0095_INCREMENT.Emp_ID
			)inc ON inc.Increment_ID = i.Increment_ID and i.Emp_ID = inc.Emp_ID left JOIN 
			T0040_DEPARTMENT_MASTER d WITH (NOLOCK) ON d.Dept_Id=i.Dept_ID left join 
			T0040_DESIGNATION_MASTER ds WITH (NOLOCK) ON ds.Desig_ID=i.Desig_Id left join 
			T0030_CATEGORY_MASTER c WITH (NOLOCK) ON c.Cat_ID  = i.Cat_ID 
			WHERE k.Cmp_ID=@cmp_Id  
			and k.FinancialYr=datepart(year,getdate()) and Status=5 and e.Emp_Superior=@emp_Id 
			having COUNT(EmpKPI_Id) > 0
			
			EXEC Get_KPIPMS_EVAL_Approval_Level @cmp_Id,@emp_Id,0,' LAD.KPIPMS_Status=3'
			
			IF EXISTS(Select 1 from T0040_KPI_AlertSetting WITH (NOLOCK) where cmp_id=@cmp_Id and KPI_Type = 4)
				BEGIN
					Insert Into #TBL_HRMS_LINKS_DASHBOARD(LinkText,LinkURL,IsAlert,IsPopup)
					SELECT 
					--isnull(KPI_Preference,0) KPI_Preference ,
						(SELECT [Alias]
							FROM [ORANGE_HRMS].[dbo].[T0040_CAPTION_SETTING]
							 where Caption='KPA' and Cmp_Id=@Cmp_ID) + ' For Review (' + cast(isnull(KPI_Preference,'')  as varchar(10))+ ')'
						,'Ess_Sup_KPIPMS_AppraisalForm.aspx?st=4',0,0
					from T0040_KPI_AlertSetting WITH (NOLOCK)
					where cmp_id=@cmp_Id and KPI_Type = 4 and isnull(KPI_Preference,'') <>''
				END
			
			-----------------------------------------------------
			
			------------END Apprisal_SupNotify-----------------------

			--need to change here remaing binal for insert data in table
			-----------Appraisal_NewObjective  table(16) to table(17) --------------------
			SET @initcount =0
			SELECT @initcount =count(*) FROM T0040_KPI_AlertSetting WITH (NOLOCK) WHERE Cmp_Id=@cmp_id and KPI_Type=3
			IF @initcount >0
				BEGIN
					SET @KPI_AlertNoDays =0
					SELECT @KPI_AlertNoDays = KPI_AlertNodays FROM T0040_KPI_AlertSetting WITH (NOLOCK) WHERE Cmp_Id=@cmp_id and KPI_Type=3	
					
					If EXISTS(SELECT Emp_Full_Name,Date_Of_Join, DATEADD(DAY,- @KPI_AlertNoDays,CONVERT(DATE, getdate())),Emp_Superior 
						FROM T0080_EMP_MASTER WITH (NOLOCK)
						WHERE  Cmp_ID=@cmp_id and Date_Of_Join = DATEADD(DAY,- @KPI_AlertNoDays,CONVERT(DATE, getdate())) 
						AND Emp_Superior=@emp_id )--ORDER BY Date_Of_Join DESC
						BEGIN
							SELECT Emp_Full_Name,Date_Of_Join, DATEADD(DAY,- @KPI_AlertNoDays,CONVERT(DATE, getdate())),Emp_Superior 
							FROM T0080_EMP_MASTER WITH (NOLOCK)
							WHERE  Cmp_ID=@cmp_id and Date_Of_Join = DATEADD(DAY,- @KPI_AlertNoDays,CONVERT(DATE, getdate())) 
							AND Emp_Superior=@emp_id
							SELECT 'Prepare Reportees Objectives for this Financial year' as response
						END
					ELSE
						BEGIN
							SELECT Emp_Full_Name,Date_Of_Join, DATEADD(DAY,- @KPI_AlertNoDays,CONVERT(DATE, getdate())),Emp_Superior 
							FROM T0080_EMP_MASTER WITH (NOLOCK)
							WHERE  Cmp_ID=@cmp_id and Date_Of_Join = DATEADD(DAY,- @KPI_AlertNoDays,CONVERT(DATE, getdate())) 
							AND Emp_Superior=@emp_id
							SELECT 0 as response
						END
						
					If EXISTS(SELECT Emp_Full_Name,Date_Of_Join, DATEADD(DAY,-@KPI_AlertNoDays,CONVERT(DATE, getdate())),Emp_Superior 
							  FROM T0080_EMP_MASTER WITH (NOLOCK)
							  WHERE  Cmp_ID=@cmp_id and Date_Of_Join = DATEADD(DAY,-@KPI_AlertNoDays,CONVERT(DATE, getdate())) and Emp_Id=@Emp_Id )--ORDER BY Date_Of_Join DESC
						BEGIN
							SELECT 'Prepare Objectives for this Financial year.' as response
						END
					ELSE
						BEGIN
							SELECT 0 as response
						END
				END	
			ELSE
				BEGIN
					SELECT Emp_Full_Name,Date_Of_Join, DATEADD(DAY,- @KPI_AlertNoDays,CONVERT(DATE, getdate())),Emp_Superior 
					FROM T0080_EMP_MASTER WITH (NOLOCK)
					WHERE  Cmp_ID=@cmp_id and Date_Of_Join = DATEADD(DAY,- @KPI_AlertNoDays,CONVERT(DATE, getdate())) 
					AND Emp_Superior=@emp_id
					SELECT 0 as response
					SELECT 0 as response
				END
			-----------------------------------------------------
			----------end Appraisal_NewObjective ---------------

			--need to change here remaing binal for insert data in table
			----------- Start Appraisal NotifyEmployee------------------
			SELECT * FROM T0080_KPIPMS_EVAL WITH (NOLOCK) WHERE Cmp_ID=@cmp_id  and KPIPMS_FinancialYr= DATEPART(YYYY,GETDATE()) and  KPIPMS_Status=1 and emp_id=@emp_id 
			SELECT EmpKPI_Id,k.Emp_Id,k.Cmp_Id,[Status],FinancialYr,emp_full_name,cat_name,dept_name,desig_name 
			FROM T0080_EmpKPI AS k WITH (NOLOCK) LEFT JOIN t0080_emp_master AS e WITH (NOLOCK) ON e.emp_id=k.emp_id LEFT JOIN 
				 T0095_INCREMENT i WITH (NOLOCK) ON i.emp_id=e.emp_id INNER JOIN 
				 (
					SELECT MAX(Increment_ID)Increment_ID,T0095_INCREMENT.Emp_ID
					FROM  T0095_INCREMENT WITH (NOLOCK) INNER	JOIN
						  (
								SELECT MAX(Increment_Effective_Date)Increment_Effective_Date,T0095_INCREMENT.Emp_ID
								FROM  T0095_INCREMENT WITH (NOLOCK)
								WHERE Cmp_ID=@cmp_id
								GROUP by Emp_ID
						  )inc1 ON inc1.Emp_ID = T0095_INCREMENT.Emp_ID
					WHERE Cmp_ID=@cmp_id
					GROUP by T0095_INCREMENT.Emp_ID
				 )inc ON inc.Increment_ID = i.Increment_ID and inc.Emp_ID = i.Emp_ID LEFT JOIN  
				 T0040_DEPARTMENT_MASTER d WITH (NOLOCK) ON d.Dept_Id=i.Dept_ID LEFT JOIN 
				 T0040_DESIGNATION_MASTER ds WITH (NOLOCK) ON ds.Desig_ID=i.Desig_Id LEFT JOIN 
				 T0030_CATEGORY_MASTER c WITH (NOLOCK) ON c.Cat_ID  = i.Cat_ID 
			where k.Cmp_ID=@Cmp_Id AND k.Emp_Id=@emp_id AND Financialyr=DATEPART(YYYY,GETDATE()) AND Status=1 


			--------------end Appraisal NotifyEmployee-------------

			--need to change here remaing binal for insert data in table
			----------Appraisal_BSC_Alert------------------------
			SELECT * FROM T0052_BSC_AlertSetting WITH (NOLOCK) WHERE BSC_AlertType =1 and Cmp_Id = @cmp_id
						
			SET @sch_date_tmp		=''
			SET @sch_date			= null
			SET @KPI_month			=null
			SET @KPI_AlertDay		=null
			SET @KPI_AlertNoDays	=null
			SET @KPI_AlertType		=null
			SET @KPI_month_str		=''
			SET @KPI_AlertDay_str	=''
			SET @msg				=0
			
			SELECT @KPI_Month = BSC_Month,@KPI_AlertDay= BSC_AlertDay,@KPI_AlertNodays=BSC_AlertNodays,@KPI_AlertType=BSC_AlertType
				FROM T0052_BSC_AlertSetting WITH (NOLOCK) WHERE Cmp_Id=@cmp_Id and BSC_AlertType=2
			
			SET @KPI_month_str = @KPI_Month
			SET @KPI_AlertDay_str = @KPI_AlertDay
			
			SELECT @sch_date_tmp = cast(datepart(YEAR,GETDATE()) as varchar(4)) +'-'+case when  LEN(@KPI_Month) > 1 then @KPI_month_str else '0'+ @KPI_month_str  end+'-'+ case when  LEN(@KPI_AlertDay) > 1 then @KPI_AlertDay_str else '0'+ @KPI_AlertDay_str  end
			SET @sch_date = DATEADD(DAY,@KPI_AlertNoDays,convert(DATETIME,@sch_date_tmp))
			
			IF @KPI_month = @cur_month
				BEGIN
					SET @day_alerttill = @KPI_AlertDay + @KPI_AlertNoDays
					If (@cur_day >= @KPI_AlertDay And @cur_day <= @day_alerttill)	
						BEGIN
							SET @msg =1										
						END
					ELSE
						 SET @msg =0
				END
			ELSE IF DATEPART(MONTH,@sch_date) = @cur_month 
				BEGIN
					SET @msg =1		
				END
			ELSE IF (@cur_month > @KPI_month And @cur_month < DATEPART(MONTH,@sch_date))
				BEGIN
					SET @msg =1			
				END
			ELSE
				BEGIN
					SET @msg =0
				END
			
			IF @msg = 1				
				SELECT 'Start the '+ CASE WHEN isnull(@KPI_AlertType,1) = 1 THEN 'Interim' ELSE 'Final' END +' Balance Score Card Assessment' as response
			ELSE
				SELECT 0 as response	
			-----------------------------------------------------

			----------end Appraisal_BSC_Alert------------------------

			--------------------DPT_Alert------------------------

			SELECT emp_id,StartDate,Enddate,DPT_Status 
			FROM T0090_DevelopmentPlanningTemplate WITH (NOLOCK) 
			WHERE Cmp_ID=@cmp_id AND CONVERT(varchar(12),GETDATE(),105) >= CONVERT(varchar(12),StartDate,105) 
			AND CONVERT(varchar(12),GETDATE(),105) <= CONVERT(varchar(12),Enddate,105) AND DPT_Status = 0 and emp_id= @emp_Id
			
			SELECT emp_id,StartDate,Enddate,PIP_Status 
			FROM T0090_PerformanceImprovementPlan WITH (NOLOCK)
			WHERE Cmp_ID=@cmp_id AND CONVERT(varchar(12),getdate(),105) >= CONVERT(varchar(12),StartDate,105) 
				  AND CONVERT(varchar(12),GETDATE(),105) <= CONVERT(varchar(12),Enddate,105) AND PIP_Status = 0 
				  AND emp_id= @emp_Id

			-----------------------------------------------------
			----------end DPT_Alert------------------------

			--------------------PublishTraining------------------
			--SELECT Training_Apr_ID,Training_Name,Training_Date,cast(Description AS VARCHAR(50)) as Description
			--FROM   dbo.V0120_HRMS_TRAINING_APPROVAL 
			--WHERE  apr_status=1 and isnull(training_apr_id,0) <> 0 and Training_Date>= cast(getdate() AS VARCHAR(11))
			--	   	and publishTraining=1 
			--ORDER BY Training_Date ASC 
			-----------------------------------------------------
			---------------end PublishTraining------------------

			-------------GetRecruitmentOpening-------------------	
			--IF EXISTS(SELECT *,Domain_Name  
			--		  FROM  T0052_HRMS_Posted_Recruitment INNER JOIN
			--				   T0010_COMPANY_MASTER on T0010_COMPANY_MASTER.Cmp_Id = T0052_HRMS_Posted_Recruitment.Cmp_id 
			--		  WHERE T0052_HRMS_Posted_Recruitment.cmp_id=@cmp_id and Posted_status = 1 and Publish_ToEmp = 1 and 
			--				   CONVERT(VARCHAR(12),Publish_FromDate,105)  <= CONVERT(VARCHAR(12),GETDATE(),105) and  CONVERT(VARCHAR(12),publish_todate ,105)  >= CONVERT(VARCHAR(12),GETDATE(),105))
			--	BEGIN
			--		SELECT Form_Url FROM T0000_DEFAULT_FORM where Form_Name = 'Current Opening Link'
			--		SELECT *,Domain_Name  
			--		FROM  T0052_HRMS_Posted_Recruitment INNER JOIN
			--				   T0010_COMPANY_MASTER on T0010_COMPANY_MASTER.Cmp_Id = T0052_HRMS_Posted_Recruitment.Cmp_id 
			--		WHERE T0052_HRMS_Posted_Recruitment.cmp_id=@cmp_id and Posted_status = 1 and Publish_ToEmp = 1 and 
			--				   CONVERT(VARCHAR(12),Publish_FromDate,105)  <= CONVERT(VARCHAR(12),GETDATE(),105) and  CONVERT(VARCHAR(12),publish_todate ,105)  >= CONVERT(VARCHAR(12),GETDATE(),105)
			--	END
			--ELSE
			--	BEGIN
			--		SELECT '' as Form_Url
			--		SELECT *,Domain_Name  
			--		FROM  T0052_HRMS_Posted_Recruitment INNER JOIN
			--				   T0010_COMPANY_MASTER on T0010_COMPANY_MASTER.Cmp_Id = T0052_HRMS_Posted_Recruitment.Cmp_id 
			--		WHERE T0052_HRMS_Posted_Recruitment.cmp_id=@cmp_id and Posted_status = 1 and Publish_ToEmp = 1 and 
			--				   CONVERT(VARCHAR(12),Publish_FromDate,105)  <= CONVERT(VARCHAR(12),GETDATE(),105) and  CONVERT(VARCHAR(12),publish_todate ,105)  >= CONVERT(VARCHAR(12),GETDATE(),105)
			--	END
			--------------------end GetRecruitmentOpening----------------------

			-------------PendingRecruitment()--------------------
			Insert Into #TBL_HRMS_LINKS_DASHBOARD(LinkText,LinkURL,IsAlert,IsPopup)
			SELECT  'Recruitment Pending List (' +CAST(COUNT(REsume_ID) as varchar(10)) +')' ,'',0,0
				--COUNT(REsume_ID) AS Resume_ID 
			FROM T0055_HRMS_Interview_Schedule WITH (NOLOCK)
			WHERE cmp_ID=@Cmp_ID AND S_Emp_ID = @emp_id AND Status =0
			-----------------------------------------------------	
			-------------end PendingRecruitment()--------------------


			------------Lnk_ManagerTraining_Feedback()-----------
			exec Get_Training_QuestionManager @emp_id
			-----------------------------------------------------
			------------end Lnk_ManagerTraining_Feedback()-----------


			------------hr_doc_aggerment()-----------------------
			DECLARE @from_date AS VARCHAR(11)
			SET @from_date = REPLACE(CONVERT(VARCHAR(11),GETDATE(),106),' ','-')
			EXEC SP_Get_HR_DOC_Data @emp_id,@cmp_id,1,1,@from_date,@from_date
			---------------end hr_doc_aggerment-------------------

			-----------Emp_check()-------------------------------
			exec P0090_Hrms_Emp_Check @cmp_id,@Emp_Id
			---------------end Emp_check-------------------------

			---------------------Emp_sup_check-------------------
			SELECT Count(Appr_detail_ID)As Count FROM V0090_Hrms_Emp_Sup_DashBoard 
			WHERE Emp_Superior= @Emp_Id and cmp_Id=@Cmp_id
			And Is_Sup_Submit = 2 
			SELECT * FROM V0090_Hrms_Emp_Sup_DashBoard 
			WHERE Emp_Superior=@Emp_Id and cmp_Id=@Cmp_id
			And Is_Sup_Submit = 2
			--------------end -Emp_sup_check-----------------

			------employee kpa setting ------start-----
			IF EXISTS(SELECT KPA_InitiateId,Cmp_ID,Emp_Id,KPA_StartDate,KPA_EndDate 
					  FROM T0055_Hrms_Initiate_KPASetting WITH (NOLOCK)
					  WHERE Emp_Id = @emp_id AND   
							KPA_StartDate <= CONVERT(varchar(10),GETDATE(),120) and ( KPA_EndDate >= CONVERT(varchar(10),GETDATE(),120) AND Initiate_Status in(0,4,3) ))--OR Initiate_Status >=3
				BEGIN				
					DECLARE @kpainit_Id NUMERIC(18,0)
					SELECT @kpainit_Id =KPA_InitiateId 
					FROM  T0055_Hrms_Initiate_KPASetting WITH (NOLOCK) INNER JOIN
							(
								SELECT (CASE WHEN Initiate_Status =3 THEN 1 WHEN Initiate_Status = 1 then 0
								WHEN (Initiate_Status in(0,4,3))--(Initiate_Status<=2 or Initiate_Status = 4) 
								THEN CASE WHEN KPA_EndDate>= CONVERT(varchar(10),GETDATE(),120) then 1 else 0  end  else 0 end) show,KPA_InitiateId as initid
								FROM T0055_Hrms_Initiate_KPASetting WITH (NOLOCK)
								WHERE Emp_Id = @emp_id
								AND   KPA_StartDate <= CONVERT(VARCHAR(10),GETDATE(),120)
							)t ON t.initid = T0055_Hrms_Initiate_KPASetting.KPA_InitiateId
					WHERE Emp_Id = @emp_id AND   
						  KPA_StartDate <= CONVERT(VARCHAR(10),GETDATE(),120)  and t.show = 1 --and ( SA_Enddate >= CONVERT(varchar(10),GETDATE(),120) and SA_Status<>1) and SA_SendToRM <> 1
						
					
					SELECT CASE WHEN isnull(Form_url,'ESS_EmployeeKPA.aspx')<>'' THEN Form_url +'?Initid=' + cast(@init_Id AS VARCHAR) ELSE 'ESS_EmployeeKPA.aspx' END Form_url
					FROM T0000_DEFAULT_FORM WITH (NOLOCK)
					WHERE Form_Name='TD_Home_ESS_354'		
				END
			
				------end employee kpa setting ------start-----


				DECLARE @todate as varchar(12) = REPLACE(CONVERT(VARCHAR(11),GETDATE(),111),'/','-')
				CREATE TABLE #FinTable_1
				(
					 Emp_id			 NUMERIC(18,0)
					,KPA_InitiateId  NUMERIC(18,0)
					,Initiate_Status NUMERIC(18,0)
					,emp_full_name   varchar(100)
					,deptid			 NUMERIC(18,0)
					,deptName		 varchar(50)
					,desigid		 NUMERIC(18,0)
					,desigName		 varchar(50)
					,InitiateStatus  varchar(50)
					,kpa_startDate	 datetime
					,Rpt_Level		 INT
					,final_Approval	 INT
					,App_Type		 VARCHAR(3)
				)
			
				INSERT INTO #FinTable_1
					EXEC P0055_Send_KPASetting_Approval @cmp_id,@emp_id,@todate,''
					SELECT COUNT(1) apprcnt FROM #FinTable_1 WHERE (Initiate_Status >= 2 and Initiate_Status<>4)
				
				DROP TABLE #FinTable_1



				--------Survey Forms-----------
				

				Insert Into #TBL_HRMS_LINKS_DASHBOARD(LinkText,LinkURL,IsAlert,IsPopup)
				Select top 1 'Fill Up The Survey Form','ess_surveyform.aspx?SurveyID'+CAST(Survey_ID as varchar(50)),0,0 from T0050_SurveyMaster WITH (NOLOCK) 
				where Cmp_ID=@Cmp_ID and 
					(@Emp_id in 
						(SELECT top 1 cast(data AS numeric(18, 0)) FROM  dbo.Split(ISNULL(dbo.T0050_SurveyMaster.survey_empid , '0'), '#') 
								WHERE data <> '') or @Branch_ID = Branch_Id ) 
					and GETDATE() >= SurveyStart_Date and CAST(GETDATE() as varchar(12)) <= Survey_OpenTill
				-----end survey forms------

				--------Holiday Callander-----------

				Insert Into #TBL_HRMS_LINKS_DASHBOARD(LinkText,LinkURL,IsAlert,IsPopup)
				values('Holiday Calendar','javascript:void(0);',0,1)
				--------End Holiday Callander-----------


				Select * from #TBL_HRMS_LINKS_DASHBOARD

				DROP TABLE #TBL_HRMS_LINKS_DASHBOARD


END

