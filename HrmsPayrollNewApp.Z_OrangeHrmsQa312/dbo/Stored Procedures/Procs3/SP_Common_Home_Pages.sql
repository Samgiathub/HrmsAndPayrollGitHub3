CREATE PROCEDURE [dbo].[SP_Common_Home_Pages]
   @Cmp_ID numeric(18,0),  
   @Branch_ID numeric(18,0)  ,
   @Type numeric ,
   @login_Id numeric(18,0)=0
AS  
	
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET ARITHABORT ON;

	Create Table #Temp
	(  
		Leave numeric(18,0),  
		Loan NUmeric(18,0),  
		Claim numeric(18,0),
		Tran_Pen numeric(18,0),
		Tran_Apr numeric(18,0), 
		Tran_Rej numeric(18,0),
		Rec_Sch numeric(18,0),
		News varchar(5000),
		leavecancellation numeric(18,0),
		travel numeric(18,0),
		travel_settlement numeric(18,0)
	)  
     
	Declare @Loan as numeric(18,0)  
	Declare @Claim as numeric(18,0)
	declare @Tran_Pen as numeric(18,0)
	Declare @Tran_Apr as numeric(18,0)
	Declare @Tran_Rej as numeric(18,0)
	Declare @Rec_Sch as numeric(18,0) 
	Declare @Leavecancel as numeric(18,0)
	Declare @travel as numeric(18,0)
	Declare @travel_settlement as numeric(18,0)
	Declare @pPrivilage_ID as varchar(Max) 
	Declare @pPrivilage_Department as varchar(max)
	Declare @pPrivilage_Vertical as varchar(max)
	Declare @pPrivilage_Sub_Vertical as varchar(max)
	Declare @Emp_Id as numeric(18,0)
	Declare @FDate as datetime

	set @travel = 0
	set @travel_settlement = 0
	set @pPrivilage_ID = '0'
	set @pPrivilage_Department = '0'
	set @pPrivilage_Vertical = '0'
	set @pPrivilage_Sub_Vertical = '0'
	set @Emp_Id = 0
	
    SELECT top 1 @pPrivilage_ID=PM.branch_id_multi,@FDate=pd.FROM_DATE
	,@pPrivilage_Department = PM.Department_Id_Multi,@pPrivilage_Vertical = PM.Vertical_ID_Multi
	,@pPrivilage_Sub_Vertical = PM.SubVertical_ID_Multi,@Emp_Id = em.Emp_ID
    from T0011_LOGIN lo WITH (NOLOCK) 
	left outer join v0080_employee_master em on em.Emp_ID = lo.Emp_ID 
	inner join T0090_EMP_PRIVILEGE_DETAILS PD WITH (NOLOCK) on lo.Login_ID = pd.Login_Id 
	inner join T0020_PRIVILEGE_MASTER PM WITH (NOLOCK) on pd.Privilege_Id = PM.Privilege_ID 
    where lo.Cmp_ID=@cmp_id and pd.Login_Id=@login_Id and ISNULL(em.emp_left,'N') = 'N' 
	and Pd.From_Date <= GETDATE()
    group by PM.branch_id_multi,pd.FROM_DATE,PM.Department_Id_Multi
	,PM.Vertical_ID_Multi,PM.SubVertical_ID_Multi,em.Emp_ID  
    order by pd.FROM_DATE DESC 

         IF	@pPrivilage_ID = '' or @pPrivilage_ID = '0'
				set @pPrivilage_ID = NULL
	
		IF @pPrivilage_Vertical = '' or @pPrivilage_Vertical = '0'
			set @pPrivilage_Vertical = NULL
			
		IF @pPrivilage_Sub_Vertical = '' or @pPrivilage_Sub_Vertical='0'
			set @pPrivilage_Sub_Vertical = NULL
		
		IF @pPrivilage_Department = '' or @pPrivilage_Department='0'
			set @pPrivilage_Department = NULL
	
		if @pPrivilage_ID is null
		Begin	
			select @pPrivilage_ID = COALESCE(@pPrivilage_ID + '#', '') + cast(Branch_ID as nvarchar(5))  
			from T0030_BRANCH_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_ID 
			set @pPrivilage_ID = @pPrivilage_ID + '#0'
		End
		
		if @pPrivilage_Vertical is null
		Begin	
			select @pPrivilage_Vertical = COALESCE(@pPrivilage_Vertical + '#', '') + cast(Vertical_ID as nvarchar(5)) 
			from T0040_Vertical_Segment WITH (NOLOCK) where Cmp_ID=@Cmp_ID 
			
			If @pPrivilage_Vertical IS NULL
				set @pPrivilage_Vertical = '0';
			else
				set @pPrivilage_Vertical = @pPrivilage_Vertical + '#0'		
		End
		if @pPrivilage_Sub_Vertical is null
		Begin	
			select   @pPrivilage_Sub_Vertical = COALESCE(@pPrivilage_Sub_Vertical + '#', '') + cast(subVertical_ID as nvarchar(5))  
			from T0050_SubVertical WITH (NOLOCK) where Cmp_ID=@Cmp_ID 
			
			If @pPrivilage_Sub_Vertical IS NULL
				set @pPrivilage_Sub_Vertical = '0';
			else
				set @pPrivilage_Sub_Vertical = @pPrivilage_Sub_Vertical + '#0'
		End
		IF @pPrivilage_Department is null
		Begin
			select   @pPrivilage_Department = COALESCE(@pPrivilage_Department + '#', '') + cast(Dept_ID as nvarchar(5)) 
			from T0040_DEPARTMENT_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_ID 		
			
			if @pPrivilage_Department is null
				set @pPrivilage_Department = '0';
			else
				set @pPrivilage_Department = @pPrivilage_Department + '#0'
		End
	
		IF object_id('tempdb..#Emp_Cons') is not null
			drop table #Emp_Cons 
			
        SELECT	I1.EMP_ID, I1.INCREMENT_ID, BRANCH_ID , I1.Vertical_ID,I1.SubVertical_ID,I1.Dept_ID
        Into #Emp_Cons
		FROM	T0095_INCREMENT I1 WITH (NOLOCK)
				INNER JOIN (SELECT MAX(INCREMENT_ID) AS INCREMENT_ID, Increment_Effective_Date, I2.Emp_ID
							FROM T0095_INCREMENT I2 WITH (NOLOCK) 
							GROUP BY I2.Increment_Effective_Date, I2.Emp_ID) I2 ON I1.Increment_ID=I2.INCREMENT_ID
							INNER JOIN (SELECT	MAX(Increment_Effective_Date) AS Increment_Effective_Date, I3.Emp_ID
										FROM	T0095_INCREMENT I3  WITH (NOLOCK)
										WHERE	I3.Increment_Effective_Date <=GETDATE() and Cmp_ID=@Cmp_ID
										GROUP BY I3.Emp_ID) I3 ON I2.Increment_Effective_Date=I3.Increment_Effective_Date AND I2.Emp_ID=I3.Emp_ID
					
		 where 	I1.Cmp_ID=@Cmp_ID  --and I.Emp_ID = @Emp_id
		 and EXISTS (select Data from dbo.Split(@pPrivilage_ID, '#') B
						Where cast(B.data as numeric)=Isnull(I1.Branch_ID,0))
		 and EXISTS (select Data from dbo.Split(@pPrivilage_Vertical, '#') VE
						Where cast(VE.data as numeric)=Isnull(I1.Vertical_ID,0))
		 and EXISTS (select Data from dbo.Split(@pPrivilage_Sub_Vertical, '#') S
						Where cast(S.data as numeric)=Isnull(I1.SubVertical_ID,0))
		 and EXISTS (select Data from dbo.Split(@pPrivilage_Department, '#') D 
						Where cast(D.data as numeric)=Isnull(I1.Dept_ID,0))    		   
				
		 
		 if @Branch_ID is null  
			 set @Branch_ID=0  
		 
		 If @Branch_ID=0  
		 BEgin
		    if (ISNULL(@pPrivilage_ID,'0')) <> '0'
		     BEGIN
		      insert into #Temp
		      Select Count(Leave_Application_ID),0,0,0,0,0,0,'',0,0,0 
		      from V0110_Leave_Application_Detail V INNER JOIN 
				   #Emp_Cons E ON E.Emp_Id = V.Emp_ID  --Addded By Jaina 09-08-2016
		      where  Application_Status in('P','F') 
					and cmp_ID=@Cmp_ID 
					      
		      Select @Loan=Count(Loan_App_ID) 
		      from V0100_LOAN_APPLICATION V INNER JOIN
				  #Emp_Cons E ON E.Emp_id = V.Emp_ID   
		      where Loan_status='N' and cmp_ID=@Cmp_ID 
		      
		      Select @Claim=Count(claim_App_ID) 
		      from V0100_Claim_Application_New V INNER JOIN
				  #Emp_Cons E ON E.Emp_id = V.Emp_ID   
		      where Claim_App_Status='P' and cmp_ID=@Cmp_ID and V.Submit_Flag=0  
		      
		      select @Tran_Pen=0,@Tran_Apr=0,@Tran_Rej=0
		      
		      Select @Leavecancel = COUNT(Leave_Approval_id) 
		      from V0150_LEAVE_CANCELLATION_APPROVAL_MAIN V Inner JOIN
		      	  #Emp_Cons E ON E.Emp_id = V.Emp_ID   
		      where is_approve =0 and Cmp_Id = @Cmp_ID  
		      
		      Select @travel=Count(travel_application_id) 
		      from V0100_TRAVEL_APPLICATION V INNER JOIN
		      	  #Emp_Cons E ON E.Emp_id = V.Emp_ID   
		      where application_status='P'  and cmp_ID=@Cmp_ID 
		      
		      Select @travel_settlement=Count(travel_set_application_id) 
		      from V0140_Travel_Settlement_Application V Inner JOIN
		      	  #Emp_Cons E ON E.Emp_id = V.Emp_ID 
		      where status='P' and cmp_ID=@Cmp_ID 
		     
		     END
		    ELSE
		     BEGIN
		      insert into #Temp
		      Select Count(Leave_Application_ID),0,0,0,0,0,0,'',0,0,0 from V0110_Leave_Application_Detail where cmp_ID=@Cmp_ID and Application_Status in('P','F')
		      Select @Loan=Count(Loan_App_ID) from V0100_LOAN_APPLICATION where Loan_status='N' and cmp_ID=@Cmp_ID 
		      
		      Select @Claim=Count(claim_App_ID) from V0100_Claim_Application_New where Claim_App_Status='P' and cmp_ID=@Cmp_ID  and Submit_Flag=0
		      select @Tran_Pen=0,@Tran_Apr=0,@Tran_Rej=0
		      Select @Leavecancel = COUNT(Leave_Approval_id) from V0150_LEAVE_CANCELLATION_APPROVAL_MAIN where is_approve =0 and Cmp_Id = @Cmp_ID  and  1=1 
		      Select @travel = Count(travel_Application_ID) from V0100_TRAVEL_APPLICATION where Application_status='P' and cmp_ID=@Cmp_ID    
		      select @travel_settlement = count(travel_set_application_id) from V0140_Travel_Settlement_Application where status='P' and cmp_ID=@Cmp_ID    
		       
		     END
		 end  
		 else  
		  begin  
		  if (ISNULL(@pPrivilage_ID,'0')) <> '0'
		     BEGIN
		      insert into #Temp
		      Select Count(Leave_Application_ID),0,0,0,0,0,0,'',0,0,0 
		      from V0110_Leave_Application_Detail V Inner JOIN
			  #Emp_Cons E ON E.Emp_id = V.Emp_ID   
		      where Application_status='P' and cmp_ID=@Cmp_ID    		   
		      
		      Select @Loan=Count(Loan_App_ID) 
		      from V0100_LOAN_APPLICATION V INNER JOIN
		       #Emp_Cons E ON E.Emp_Id = V.Emp_ID   
			   where Loan_status='N' and cmp_ID=@Cmp_ID 
		      
		      Select @Claim=Count(claim_App_ID)
		      from V0100_Claim_Application_New V Inner JOIN
		       #Emp_Cons E ON E.Emp_Id = V.Emp_ID   
		      where Claim_App_Status='P' and cmp_ID=@Cmp_ID	and V.Submit_Flag=0	      
		      
		      select @Tran_Pen=0,@Tran_Apr=0,@Tran_Rej=0
		      
		      Select @Leavecancel = COUNT(Leave_Approval_id) 
		      from V0150_LEAVE_CANCELLATION_APPROVAL_MAIN  V Inner JOIN
				   #Emp_Cons E ON E.Emp_Id = V.Emp_Id 
		      where is_approve =0 and Cmp_Id = @Cmp_ID  
		      
		      Select @travel=Count(travel_application_id)
		      from V0100_TRAVEL_APPLICATION  V Inner JOIN
				#Emp_Cons E ON E.Emp_ID = V.Emp_ID   
		      where application_status='P' and cmp_ID=@Cmp_ID 
		      
		      Select @travel_settlement=Count(travel_set_application_id) 
		      from V0140_Travel_Settlement_Application V Inner JOIN
		        #Emp_Cons E ON E.Emp_Id = V.emp_id   
		      where status='P' and cmp_ID=@Cmp_ID 

		     END
		    ELSE
		     BEGIN
		      insert into #Temp
		      SELECT Count(Leave_Application_ID),0,0,0,0,0,0,'',0,0,0 
			  from V0110_Leave_Application_Detail where Application_status='P' and cmp_ID=@Cmp_ID

		      SELECT @Loan=Count(Loan_App_ID) from V0100_LOAN_APPLICATION where Loan_status='N' and cmp_ID=@Cmp_ID 
		      SELECT @Claim=Count(claim_App_ID) from V0100_Claim_Application_New where Claim_App_Status='P' and cmp_ID=@Cmp_ID and Submit_Flag=0
		      SELECT @Leavecancel = COUNT(Leave_Approval_id) from V0150_LEAVE_CANCELLATION_APPROVAL_MAIN where is_approve =0 and Cmp_Id = @Cmp_ID  and  1=1 
		      SELECT @travel = Count(travel_Application_ID) from V0100_TRAVEL_APPLICATION where Application_status='P' and cmp_ID=@Cmp_ID and branch_id=@branch_id   
		      SELECT @travel_settlement = count(travel_set_application_id) from V0140_Travel_Settlement_Application where status='P' and cmp_ID=@Cmp_ID  and branch_id=@branch_id
		     END
		   
		   select @Rec_Sch=ISNULL(count(distinct(resume_id)),0) 
		   from T0055_hrms_interview_schedule 
		   WITH (NOLOCK) where cmp_id = @cmp_id	
		  End 
		    
		      
		   Declare @News as varchar(5000)  
		   Declare @News_Letter_ID numeric(18,0)  
		   Declare @News_Title varchar(50)  
		   Declare @News_Description varchar(1000)  
		   set @News=''  
		  
		     
	   IF OBJECT_ID('tempdb..#BranchList') is not null
		  Begin
			Drop Table #BranchList
		  End    

		Create Table #BranchList
		(
			Branch_ID Numeric
		)

		Insert into #BranchList
		Select Data From dbo.Split(@pPrivilage_ID,'#')
	   
		Declare Cur_News cursor for         
		  select Distinct News_Letter_ID,News_Title,News_Description  
			from  T0040_NEWS_LETTER_MASTER WITH (NOLOCK) 
				  Cross Join #BranchList B
		  where Cmp_ID=@Cmp_ID And Start_Date <= Cast(Getdate() AS varchar(11)) 
		  And End_Date >= Cast(getdate() AS varchar(11)) 
		  And Is_Visible=1 and Flag_T =isnull(0,1)  
		  AND 1 = (Case When isnull(B.Branch_ID,0) = 0 Then 1 
				   ELSE Case When CHARINDEX('#'+ Cast(B.Branch_ID as varchar(10))+'#' ,'#'+Isnull(Branch_Wise_News_Announ,@Branch_ID)+'#') > 0 
				   Then 1 Else 0 END END)
		  Order by News_Letter_ID   
		  open Cur_News        
		 fetch next from Cur_News into  @News_Letter_ID,@News_Title,@News_Description  
		 While @@Fetch_Status=0        
		  begin        
			 set @News = @News +'<B>' + @News_Title +'</B>' + ' : ' + @News_Description + '                 '  
		   fetch next from Cur_News into  @News_Letter_ID,@News_Title,@News_Description  
		  end        
		 close Cur_News        
		 Deallocate Cur_News  
		 
			if @News <> ''  
				set @News = '<Marquee scrollamount=2 onmouseover="this.stop();" onmouseout="this.start();">' + @News + '</Marquee>'     
		     
		      
		      
			Update #Temp set News=@News, Loan=@Loan,Claim=@Claim,Tran_Pen=@Tran_Pen,Tran_Apr=@Tran_Apr,Tran_Rej=@Tran_Rej,Rec_Sch=@Rec_Sch,leavecancellation = @Leavecancel ,travel=@travel,travel_settlement=@travel_settlement
		    
			--Don't Comment the below line is used to load the home.aspx page comment by deepal 27102022
			select Leave,Loan,Claim,Tran_Pen,Tran_Apr,Tran_Rej,isnull(Rec_Sch,0) as Rec_Sch,News,leavecancellation,travel,travel_settlement
			from #Temp  
			--Don't Comment the below line is used to load the home.aspx page comment by deepal 27102022
		  
		Declare @Upcoming_Count as Integer
		set @Upcoming_Count = 0 

		exec Get_Birthday_Anniversary_reminder @Cmp_ID,@pPrivilage_ID,@pPrivilage_Department,@pPrivilage_Vertical
		,@pPrivilage_Sub_Vertical
	
         if @Branch_ID =0
          set @Branch_ID = null
        
         Declare @Gender table
		 (
			  Cmp_ID numeric(18,0),
			  branch_id numeric(18,0),
			  branch_name varchar(50),
			  total_emp numeric(18,0),
			  left_emp numeric(18,0),
			  new_emp numeric(18,0),		  
			  Sum_Total_emp numeric(18,0),   
			  Sum_Total_Left_emp numeric(18,0),
			  Sum_Total_new_emp  numeric(18,0) 
		 )

		if (ISNULL(@pPrivilage_ID,'0')) <> '0'	
			insert into @Gender(Cmp_ID,branch_id,branch_name,total_emp)
            select Cmp_ID,V.branch_id,V.branch_name,count(E.emp_id) as total 
            from v0080_employee_master V inner JOIN
            #Emp_Cons E ON E.Emp_Id = V.Emp_ID  
            where cmp_id=@cmp_id and emp_left='N'
			and EXISTS (select Data from dbo.Split(@pPrivilage_ID, '#') B Where cast(B.data as numeric)=Isnull(E.Branch_ID,0))
					and EXISTS (select Data from dbo.Split(@pPrivilage_Vertical, '#') VE Where cast(VE.data as numeric)=Isnull(E.Vertical_ID,0))
					and EXISTS (select Data from dbo.Split(@pPrivilage_Sub_Vertical, '#') S Where cast(S.data as numeric)=Isnull(E.SubVertical_ID,0))
					and EXISTS (select Data from dbo.Split(@pPrivilage_Department, '#') D Where cast(D.data as numeric)=Isnull(E.Dept_ID,0))    		   
			group by V.branch_id,branch_name,Cmp_ID		
	    else
			insert into @Gender(Cmp_ID,branch_id,branch_name,total_emp)
            select Cmp_ID,branch_id,branch_name,count(emp_id) as total 
            from v0080_employee_master 
            where cmp_id=@cmp_id and branch_id=isnull(@branch_id,branch_id) and emp_left='N' 
            group by branch_id,branch_name,Cmp_ID
                 
		---Added By Mihir 09012012
		Declare @Sum_Total_emp as numeric(18,0)
		select @Sum_Total_emp = ISNULL(SUM(AM.total_emp),0) from @Gender AM
		update @Gender
		set Sum_Total_emp = @Sum_Total_emp
		from @Gender AM 
		---End of Added By Mihir 09012012
		
		update @Gender
		set left_emp = isnull(LT.left_emp,0)
		from @Gender AM inner join (select em.Cmp_ID,count(em.emp_id)as left_emp ,bm.branch_name,I.branch_id 
		from v0080_employee_master em
		inner join T0095_Increment I on em.emp_id=i.Emp_ID and i.Cmp_ID=em.Cmp_ID
			INNER JOIN (SELECT MAX(Increment_Id) AS Increment_ID,i2.Emp_ID  
							FROM T0095_Increment I2
								INNER JOIN (SELECT	MAX(INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I3.EMP_ID
											FROM	T0095_INCREMENT I3 
											WHERE	I3.Increment_Effective_Date <= GETDATE() 
											GROUP BY I3.Emp_ID
											) I3 ON I2.Increment_Effective_Date=I3.INCREMENT_EFFECTIVE_DATE AND I2.Emp_ID=I3.Emp_ID																		
							GROUP BY i2.emp_ID 
						) Qry ON I.Emp_ID = Qry.Emp_ID AND I.Increment_ID = Qry.Increment_ID						  
			INNER JOIN T0030_BRANCH_MASTER bm ON IsNull(I.Branch_ID, 0) =bm.Branch_ID
		where Em.cmp_id=@cmp_id and emp_left='Y' And Month(Emp_Left_Date)=Month(dateadd(mm,-1,GetDate())) 
		And Year(Emp_Left_Date) = Year(dateadd(mm,-1,GetDate())) group by I.branch_id,Bm.branch_name,Em.Cmp_ID)LT -- Emp_Left_Date changed by mitesh on 17072012 previously it was reg_accepted_date
		ON AM.branch_id = LT.branch_id
		
		---Added By Mihir 09012012
		Declare @Sum_Total_Left_emp As numeric(18,0)
		select @Sum_Total_Left_emp = ISNULL(SUM(AM.left_emp),0) from @Gender AM
		update @Gender
		set Sum_Total_Left_emp = @Sum_Total_Left_emp
		from @Gender AM 

		update @Gender
		set new_emp = isnull(LT.new_emp,0)
		from @Gender AM inner join (select em.Cmp_ID,count(em.emp_id)as new_emp ,bm.branch_name,I.branch_id 
		from v0080_employee_master em
		inner join T0095_Increment I on em.emp_id=i.Emp_ID and i.Cmp_ID=em.Cmp_ID
			INNER JOIN (SELECT MAX(Increment_Id) AS Increment_ID,i2.Emp_ID  
							FROM T0095_Increment I2
								INNER JOIN (SELECT	MAX(INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I3.EMP_ID
											FROM	T0095_INCREMENT I3 
											WHERE	I3.Increment_Effective_Date <= GETDATE() and I3.Increment_Type='Joining'
											GROUP BY I3.Emp_ID
											) I3 ON I2.Increment_Effective_Date=I3.INCREMENT_EFFECTIVE_DATE AND I2.Emp_ID=I3.Emp_ID																		
							GROUP BY i2.emp_ID 
						) Qry ON I.Emp_ID = Qry.Emp_ID AND I.Increment_ID = Qry.Increment_ID						  
			INNER JOIN T0030_BRANCH_MASTER bm ON IsNull(I.Branch_ID, 0) =bm.Branch_ID
			where em.cmp_id=@cmp_id And Month(date_of_join)=Month(dateadd(mm,-1,GetDate())) And 
		Year(date_of_join) = Year(dateadd(mm,-1,GetDate())) group by I.branch_id,BM.branch_name,EM.Cmp_ID)LT
		ON AM.branch_id = LT.branch_id	

		
		Declare @Sum_Total_new_emp As numeric(18,0)
		select @Sum_Total_new_emp = ISNULL(SUM(AM.new_emp),0) from @Gender AM
		update @Gender
		set Sum_Total_new_emp = @Sum_Total_new_emp
		from @Gender AM 
	
		select * from @Gender
          
        declare @for_date varchar(50) 
		set @for_date= cast(getdate() as varchar(11))
        select count(training_app_id)as training from v0100_HRMS_TRAINING_APPLICATION where cmp_id = @cmp_id and app_status=0 and branch_id=isnull(@branch_id,branch_id)
        select Training_Apr_ID,Training_Name,Training_Date,Description   --Change by Ripal 17July2014
		from V0120_HRMS_TRAINING_APPROVAL	 
		where cmp_id=@cmp_id and apr_status =1 and Training_Date>= @for_date and GETDATE()>= DATEADD(DAY,-10,Training_Date)  order by Training_Date asc
		 
		  
		 if isnull(@Branch_ID,0)=0   
			select top 1 training_name,* from v0120_HRMS_TRAINING_APPROVAL where training_end_date<=getdate() and dateadd(dd,7,training_end_date)>=getdate() and cmp_id=@cmp_id order by training_end_date desc 
		 else
		   select top 1 training_name,* from v0120_HRMS_TRAINING_APPROVAL where training_end_date<=getdate() and dateadd(dd,7,training_end_date)>=getdate() and cmp_id=@cmp_id and isnull(branch_id,0)=@branch_id order by training_end_date desc 
		   
		declare @count as numeric(18,0)
		declare @training_apr_id as numeric(18,0)
		 if isnull(@branch_id,0) <> 0
		  begin
			
			 set @training_apr_id =0 
			select @count = count(tran_emp_detail_id),@training_apr_id = training_apr_id from V0130_HRMS_TRAINING_EMPLOYEE_DETAIL group by training_apr_id,emp_tran_status,cmp_id having cmp_id=@cmp_ID and emp_tran_status=0 and training_apr_id in (select top 1 Training_Apr_ID from V0130_HRMS_TRAINING_ALERT where cmp_id=@cmp_ID and branch_id=@branch_id and isnull(training_apr_id,0) <> 0 and Training_Date>= getdate() and Training_Date<=dateadd(day,alerts_Start_Days,getdate()) order by newid()) and emp_tran_status=0
			if @count > 0
			   select top 1 training_apr_id,@count as emp_count,training_date,training_name,cast(description as varchar(20))as description from v0120_HRMS_TRAINING_APPROVAL where training_apr_id=@training_apr_id and cmp_id =@cmp_id
			 else
			   select top 1 training_apr_id from v0120_HRMS_TRAINING_APPROVAL where training_apr_id=@training_apr_id and cmp_id =@cmp_id and apr_status = 1
			end
		 else
		  begin
			 set @training_apr_id =0 
			select @count = count(tran_emp_detail_id),@training_apr_id = training_apr_id from V0130_HRMS_TRAINING_EMPLOYEE_DETAIL group by training_apr_id,emp_tran_status,cmp_id having cmp_id=@cmp_ID and emp_tran_status=0 and training_apr_id in (select top 1 Training_Apr_ID from V0130_HRMS_TRAINING_ALERT where cmp_id=@cmp_ID and isnull(training_apr_id,0) <> 0 and Training_Date>= getdate() and Training_Date<=dateadd(day,alerts_Start_Days,getdate()) order by newid()) and emp_tran_status=0
			if @count > 0
			   select top 1 training_apr_id,@count as emp_count,training_date,training_name,cast(description as varchar(20))as description from v0120_HRMS_TRAINING_APPROVAL where training_apr_id=@training_apr_id and cmp_id =@cmp_id
			 else
				select top 1 training_apr_id from v0120_HRMS_TRAINING_APPROVAL where training_apr_id=@training_apr_id  and cmp_id =@cmp_id
			 end  
			-- for common request 06-oct-2010
			select count(*) as total_pending from V0090_Common_Request_Detail where emp_login_id=@Login_id and status=0
			
			select top 2 request_id,request_type,case 
			when cast(request_date as varchar(11))=cast(getdate() as varchar(11)) 
			then  cast(DATEPART ( hh , request_date) as varchar(10)) + ':' + cast(DATEPART ( mi , request_date) as varchar(10))
			else cast(request_date as varchar(11))end as request_date
			,cast (request_detail as varchar(30)) as request_detail
			,case when isnull(emp_name1,'')='' then replace(login_name1,domain_name1,'') else emp_name1 end   as posted_by 
			from V0090_Common_Request_Detail where login_id=@login_Id and status=0 order by newid(),request_date desc

			select count(*) as total_posted from V0090_Common_Request_Detail where login_id=@login_Id and status=0 

			select top 2 request_id,request_type
			,case when cast(request_date as varchar(11))=cast(getdate() as varchar(11)) then  cast(DATEPART ( hh , request_date) 
			as varchar(10)) + ':' + cast(DATEPART ( mi , request_date) as varchar(10))else cast(request_date as varchar(11))end 
			as request_date,cast(feedback_detail as varchar(30))as feedback_detail
			,case when isnull(emp_name,'')='' then replace(login_name,domain_name,'') else emp_name end   as replied_by 
			from V0090_Common_Request_Detail where EMP_login_id=@login_id and status=1 order by newid(),request_date desc
			select  count(*)as total_feedback from V0090_Common_Request_Detail where EMP_login_id=@login_id and status=1
			
			
			DECLARE @ShowCurrMonth_Count NUMERIC 
			SET @ShowCurrMonth_Count = 0
			
			SELECT @ShowCurrMonth_Count = ISNULL(Setting_Value,0) 
			FROM T0040_SETTING WITH (NOLOCK) WHERE Cmp_ID=@Cmp_ID 
			and Setting_Name='Show Current Month Attendance Regularization Count On Home Page'
			 
			IF @ShowCurrMonth_Count = 1
			BEGIN
			
					if (ISNULL(@pPrivilage_ID,'0')) = '0'
						begin					
							Select count(Emp_Id) as LateComer From View_Late_Emp Where cmp_ID=@Cmp_ID AND Chk_By_Superior=0  
							and month(For_Date)=MONTH(GETDATE())  and year(For_Date)= year(GETDATE()) 
						end
					else
						begin
								Select count(E.Emp_Id) as LateComer 
								From View_Late_Emp V Inner JOIN
									#Emp_Cons E ON E.Emp_id = V.Emp_ID   
								Where cmp_ID=@Cmp_ID And Chk_By_Superior=0 
								and  month(For_Date)=MONTH(GETDATE())  and year(For_Date)= year(GETDATE())
							
						end
				END
			ELSE
				BEGIN
					if (ISNULL(@pPrivilage_ID,'0')) = '0'
						begin					
							Select count(Emp_Id) as LateComer From View_Late_Emp Where cmp_ID=@Cmp_ID AND Chk_By_Superior=0  
						end
					else
						begin
							Select count(E.Emp_Id) as LateComer 
							From View_Late_Emp V Inner JOIN
							#Emp_Cons E ON E.Emp_id= V.Emp_ID   
							Where cmp_ID=@Cmp_ID And Chk_By_Superior=0 
						end
				END
			
			 
				
			If (ISNULL(@pPrivilage_ID,'0')) = '0'
				begin	
					SELECT COUNT(Login_Id) as InActive_Users 
					FROM T0011_LOGIN WITH (NOLOCK) 
					WHERE Cmp_Id=@Cmp_ID and Is_Active=0 and isnull(Emp_ID,0) <> 0
				end
			Else	
				BEGIN
					SELECT COUNT(T.LOGIN_ID) AS INACTIVE_USERS 
					FROM T0011_LOGIN T WITH (NOLOCK) 
					INNER JOIN #EMP_CONS E ON E.EMP_ID = T.EMP_ID   
					WHERE T.CMP_ID=@CMP_ID AND IS_ACTIVE=0 AND ISNULL(E.EMP_ID,0) <> 0
				END
			
			
			
			If (ISNULL(@pPrivilage_ID,'0')) <> '0' AND @pPrivilage_ID <> ''   
			begin											
					Select COUNT(Emp_ID) As Probation_Over_User From V0080_EMP_PROBATION_GET 
					Where Cmp_ID = @Cmp_ID	and Emp_Left <> 'Y' 
					and ((probation_date >= GETDATE() and probation_date <= DATEADD(DD,30,GETDATE())) OR (probation_date <= GETDATE()) 
					AND Is_On_Probation = 1 )
				end
			else
				begin	
					Select COUNT(E.Emp_ID) As Probation_Over_User 
					From V0080_EMP_PROBATION_GET V Inner JOIN
					 #Emp_Cons E ON E.Emp_Id = V.Emp_ID   
					Where Cmp_ID = @Cmp_ID	and Emp_Left <> 'Y' 
					and ( probation_date >= GETDATE() and probation_date <= DATEADD(DD,30,GETDATE()) OR (probation_date <= GETDATE() 
					AND Is_On_Probation = 1 ))  
					
				end
			
			If (ISNULL(@pPrivilage_ID,'0')) = '0'
				begin	
					Select ISNULL(COUNT(Compoff_App_ID),0) As COMPOFF From V0110_COMPOFF_APPLICATION_DETAIL
					Where Cmp_ID = @Cmp_ID	and Application_Status='p'
				end
			else
				begin
					Select COUNT(Compoff_App_ID) As COMPOFF 
					From V0110_COMPOFF_APPLICATION_DETAIL V INNER JOIN
					#Emp_Cons E ON E.Emp_Id = V.Emp_ID  
					Where Cmp_ID = @Cmp_ID and Application_Status='p'
				end
				
				
			------------------------------
			
			If (ISNULL(@pPrivilage_ID,'0')) = '0'
				begin	
					Select ISNULL(COUNT(Op_Holiday_app_ID),0) As Optional_Holiday 
					From V0100_Optional_Holiday_Application 
					Where Cmp_ID = @Cmp_ID And Op_Holiday_Status='P' And Emp_Left <> 'Y'
				end
			else
				begin
					Select COUNT(Op_Holiday_app_ID) As Optional_Holiday 
					From V0100_Optional_Holiday_Application V Inner JOIN
						#Emp_Cons E ON E.Emp_Id = V.Emp_ID  
					Where Cmp_ID = @Cmp_ID and Op_Holiday_Status='P' And Emp_Left <> 'Y' 
				end
				
		If (ISNULL(@pPrivilage_ID,'0')) = '0'
				begin	
					Select ISNULL(COUNT(Rc_App_ID),0) As Reim_App 
					From V0100_RC_Application Where Cmp_ID = @Cmp_ID	and APP_Status=0 and Submit_Flag=0
				end
			else
				begin
					Select COUNT(Rc_App_ID) As Reim_App 
					From V0100_RC_Application V Inner JOIN
					#Emp_Cons E ON E.Emp_Id = V.Emp_ID  
					Where Cmp_ID = @Cmp_ID and APP_Status=0 and Submit_Flag=0
				end		
				

	Declare @Qry as varchar(5000)
	if @pPrivilage_ID <> '0'
	Begin
		set @Qry = 'SELECT count(AR_App_ID) cnt_AR_APPLICATION 
		FROM V0100_AR_APPLICATION  V INNER JOIN #Emp_Cons E ON E.Emp_ID = V.Emp_ID
		WHERE Cmp_ID = ' + cast(@Cmp_ID as varchar(10)) + ' and App_Status = 0'
		exec (@Qry)
	End
	Else
	Begin
		select count(AR_App_ID) cnt_AR_APPLICATION from V0100_AR_APPLICATION 
		where Cmp_ID = @Cmp_ID and App_Status = 0
	End

	If Exists(SELECT TOP 1 AD_ID FROM T0050_AD_MASTER WITH (NOLOCK) Where CMP_ID=@Cmp_ID AND AD_DEF_ID=14) 
		SELECT CAST(1 as bit) AS Has_GPF
	ELSE
		SELECT CAST(0 as bit) AS Has_GPF

	
	If (ISNULL(@pPrivilage_ID,'0')) = '0'
	begin	
		Select ISNULL(COUNT(PreCompOff_App_ID),0) As PRECOMPOFF 
		From V0110_PrecompOff_Application Where Cmp_ID = @Cmp_ID and App_Status='p'
	end
	else
	begin
		Select COUNT(PreCompOff_App_ID) As PRECOMPOFF 
		From V0110_PrecompOff_Application V Inner JOIN
		 #Emp_Cons E ON E.Emp_Id = V.Emp_ID  
		Where Cmp_ID = @Cmp_ID and App_Status='p'
	End

	IF (ISNULL(@pPrivilage_ID,'0')) = '0'
		BEGIN	
			SELECT ISNULL(COUNT(App_ID),0) AS GatePass_App
			FROM V0100_GATE_PASS_APPLICATION WHERE Cmp_ID = @Cmp_ID AND App_Status = 'P'
		END
	ELSE
		BEGIN
			SELECT COUNT(App_ID) AS GatePass_App 
			FROM V0100_GATE_PASS_APPLICATION V INNER JOIN
			 #Emp_Cons E ON E.Emp_Id = V.Emp_ID   
			WHERE Cmp_ID = @Cmp_ID AND App_Status = 'P' 
		END

	-- Active / In Active User For Mobile -----
	SELECT COUNT(Emp_ID) AS InActive_MobileUser 
	FROM T0080_EMP_MASTER WITH (NOLOCK) 
	WHERE Cmp_Id=@Cmp_ID 
	AND is_for_mobile_Access=0 
	AND (Emp_Left = 'N' OR (Emp_Left = 'Y' AND Emp_Left_Date > GETDATE()))

	Declare @StrWhere varchar(max)
	IF (ISNULL(@pPrivilage_ID,'0')) <> '0'
	begin
		set @StrWhere = 'and EXISTS (select Data from dbo.Split('''+@pPrivilage_ID+''', ''#'') B Where cast(B.data as numeric)=Isnull(I.Branch_ID,0))'
	end
	exec SP_Get_Employee_Retirement_Records @Cmp_ID=@Cmp_ID,@Type=1,@Days=60,@StrWhere=@StrWhere

	--///////////////////////////// GEt Company Contract expred from branch (Complaince ) ////////////////////////// Add by tejas for APM terminal
	SELECT 
			COUNT((
					CASE 
						WHEN T.[Status] = 'Active'
							THEN 1
						END
					)) AS 'Active'
			,COUNT((
					CASE 
						WHEN T.[Status] = 'Expired Soon'
							THEN 1
						END
					)) AS 'Expired Soon'
			,COUNT((
					CASE 
						WHEN T.[Status] = 'Expired'
							THEN 1
						END
					)) AS 'Compline_Contract_Expired'
			
		FROM (
			SELECT CASE 
					WHEN DATEDIFF(DAY, GETDATE(), CTD.Date_Of_Termination) > 30
						THEN 'Active'
					WHEN DATEDIFF(DAY, GETDATE(), CTD.Date_Of_Termination) <= 30
						AND DATEDIFF(DAY, GETDATE(), CTD.Date_Of_Termination) > 0
						THEN 'Expired Soon'
					ELSE 'Expired'
					END AS 'Status'
			FROM T0030_BRANCH_MASTER BM
			INNER JOIN T0035_CONTRACTOR_DETAIL_MASTER CTD ON CTD.Branch_ID = BM.Branch_ID
			INNER JOIN (
				SELECT MAX(Date_Of_Termination) Date_Of_Termination
					,Branch_ID
				FROM T0035_CONTRACTOR_DETAIL_MASTER
				GROUP BY Branch_ID,Nature_Of_Work
				) LCTD ON LCTD.Branch_ID = CTD.Branch_ID
				AND LCTD.Date_Of_Termination = CTD.Date_Of_Termination
			WHERE BM.Cmp_ID = 1
				AND BM.IsActive = 1
				AND BM.Is_Contractor_Branch = 1
			) T

	--//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

RETURN  


