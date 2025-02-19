
--exec SP_Get_HR_DOC_Data @emp_id=656,@Cmp_ID=120,@Display_Joinining=0,@status=0,@from_date='18-Oct-2023',@to_date='18-Oct-2023',@HR_DOC_ID='23',@type='1'	
---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE Procedure [dbo].[SP_Get_HR_DOC_Data]
   @emp_id  numeric(18,0) 
  ,@Cmp_ID  numeric (18,0)
  ,@Display_Joinining int
  ,@status int =0
  ,@from_date datetime
  ,@to_date datetime
  ,@HR_DOC_ID numeric (18,0) = 0
  ,@type int =0 
As

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	if @from_date= @to_date
	  set @to_date = dateadd(mm,-1,@to_date)
	declare @for_date varchar(11)
	set @for_date = cast(@from_date as varchar(11))
	declare @todate varchar(11)
	set @todate = cast(dateadd(dd,30,@from_date) as varchar(11))
	
	declare @Doc_content as nvarchar(Max) --Mukti 07102015 varchar to nvarchar
	set @Doc_content = ''
	declare @gender	char(1)
	declare @policygen char(1)
	declare @flaggender char(1) = ''
	Declare @Branch_ID as numeric(18,0)  
	Declare @Grd_ID as numeric(18,0)
	Declare @Dept_ID as numeric(18,0)
	Declare @Desig_ID as numeric(18,0)
	Declare @Branch_name as numeric(18,0)  
	Declare @Grd_name as numeric(18,0)
	Declare @Dept_name as numeric(18,0)
	Declare @Desig_name as numeric(18,0)
	declare @company_name as varchar(100)
	Declare @monthly_ctc as numeric(18,0)--added on 29 may 2012
	Declare @annual_ctc as numeric(18,0)--added on 29 may 2012
	Declare @FlagEss as numeric(18,0)
	Declare @Join_Days as varchar(100) = ''
	Declare @Current_Date as datetime = Getdate()
	declare @New_Join_Days datetime
	declare @FlagVal numeric(18,0) = 0
	select @company_name=cmp_name from t0010_company_master WITH (NOLOCK) where cmp_id=@cmp_id	
	select @FlagEss = Display_Ess from T0040_HR_DOC_MASTER WITH (NOLOCK) where cmp_id=@cmp_id and HR_DOC_ID = @HR_DOC_ID
	select @Join_Days = isnull(Join_Days,0),@policygen = gender from T0040_HR_DOC_MASTER WITH (NOLOCK) where cmp_id=@cmp_id and HR_DOC_ID = @HR_DOC_ID	
	
	--set @New_Join_Days = dateadd(day,-30,GETDATE())
	-- Added by Deepali -18102023
	if(@Join_Days ='')
	begin
	set @Join_Days ='0'
	End
		 
	Declare @Group_Join_Date as Datetime
	Declare @Joining_Date as Datetime
	Select @Group_Join_Date = GroupJoiningDate from T0080_EMP_MASTER where Cmp_ID = @Cmp_ID and Emp_ID = @emp_id
	Select @Joining_Date = Date_Of_Join,@gender = Gender from T0080_EMP_MASTER where Cmp_ID = @Cmp_ID and Emp_ID = @emp_id

	 if @policygen = 'A' 
	 begin
		Set @flaggender = 'A'
	 end
	 else if @policygen = 'M' and @gender = 'M'
	 begin
		Set @flaggender = 'M'
	 end
	 else if @policygen = 'F' and @gender = 'F'
	 begin
		Set @flaggender = 'F'
	 end

	if @Group_Join_Date is not null
	Begin 

		if @Join_Days <> ''
		Begin
	--		 print 'Deep1'
	--Print  @Join_Days
	--Return
			set @New_Join_Days = dateadd(day,Cast(@Join_Days as numeric),@Group_Join_Date)
		End
		if @Display_Joinining =1 and @FlagEss = 1
		Begin
	--		 print 'Deep2'
	--Print  @Display_Joinining
	--Return
			set @FlagVal = 1
			   if Cast(@Current_Date as Date) <= Cast(@New_Join_Days as Date) and Cast(@Current_Date as Date) >= Cast(@Group_Join_Date as Date)
		       Begin 
			   	
					if not exists(select Emp_doc_ID from V0090_EMP_HR_DOC_Detail where accepeted_status <>'Pending' and --accepted_date>=@from_date  and  and accepted_date<=@to_date
		        		Emp_id=@emp_id and HR_DOC_ID = @HR_DOC_ID and doc_title like (select doc_title from T0040_HR_DOC_MASTER WITH (NOLOCK) Where Cmp_ID = @Cmp_ID 
		        		and (isnull(gender,'M')='A' OR isnull(gender,'M')=@gender) and isnull(Display_Joinining,0)= @Display_Joinining and (HR_DOC_ID = @HR_DOC_ID or @HR_DOC_ID = 0)
		        		and(Branch_id is null or isnull(Branch_ID,0) = isnull(@Branch_ID ,isnull(Branch_ID,0)))
		        		and(Grd_id is null or isnull(Grd_ID,0) = isnull(@Grd_ID ,isnull(Grd_ID,0)) or isnull(@Grd_ID,0)=0)
		        		and (Dept_id is null or isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))or isnull(@Dept_ID,0)=0)
		        		and (Desig_ID is null or Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0)) or isnull(@Desig_ID,0)=0))
		        		)
		        		begin 		
		        				
								
		        				select top 1 * from T0040_HR_DOC_MASTER WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and gender = @flaggender and
		        				--(isnull(gender,'M')='A' OR isnull(gender,'M')=@gender) and 
		        				isnull(Display_Joinining,0)=CASE WHEN isnull(Display_Joinining,0) = 0 THEN isnull(Display_Joinining,0) ELSE @Display_Joinining END and (HR_DOC_ID = @HR_DOC_ID or @HR_DOC_ID = 0)
		        				and (Branch_id is null or isnull(Branch_ID,0) = isnull(@Branch_ID ,isnull(Branch_ID,0)) or isnull(Branch_ID,0) = 0)
		        				and (Grd_id is null or isnull(Grd_ID,0) = isnull(@Grd_ID ,isnull(Grd_ID,0)) or isnull(Grd_ID,0) = 0)
		        				and (Dept_id is null or isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))or isnull(Dept_ID,0) = 0)
		        				and (Desig_ID is null or Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0)) or isnull(Desig_ID,0) = 0)				
		        				order by HR_DOC_ID desc
		        				set @status =0
		        				
		       end
		       else
		       begin
			   --print 'sss'

							SELECT @status=1 FROM V0090_EMP_HR_DOC_Detail where accepted_date>=@from_date and accepted_date<=@to_date and Emp_id=@emp_id and doc_title like (select doc_title from T0040_HR_DOC_MASTER WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and gender='' and 
		        				(isnull(gender,'M')='A' OR isnull(gender,'M')=@gender) and isnull(Display_Joinining,0)=@Display_Joinining and (isnull(Branch_ID,0) = isnull(@Branch_ID ,isnull(Branch_ID,0)) or isnull(branch_id,0)=0)and (isnull(Grd_ID,0) = isnull(@Grd_ID ,isnull(Grd_ID,0)) or isnull(Grd_ID,0)=0)and (isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0)) or isnull(@Dept_ID,0)=0)and (Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0)) or isnull(Desig_ID,0)=0))
		        			   
		        				IF @status = 1
		        				 BEGIN
		        					SET @emp_id=0
		        					RETURN
		        				 END
		        			   select * from V0090_EMP_HR_DOC_Detail where accepted_date>=@from_date and accepted_date<=@to_date and Emp_id=@emp_id and 
		        			   doc_title like(select doc_title from T0040_HR_DOC_MASTER WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and gender='' and (isnull(gender,'M')='A' OR isnull(gender,'M')=@gender) and 
		        			   isnull(Display_Joinining,0)=@Display_Joinining and (isnull(Branch_ID,0) = isnull(@Branch_ID ,isnull(Branch_ID,0)) or isnull(branch_id,0)=0)
							   and (isnull(Grd_ID,0) = isnull(@Grd_ID ,isnull(Grd_ID,0)) or isnull(Grd_ID,0)=0)and (isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0)) or 
							   isnull(@Dept_ID,0)=0)and (Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0)) or isnull(Desig_ID,0)=0))
		        			   set @status = 1
 		       end	
		End
	End

	End
	Else
	Begin

		set @New_Join_Days = dateadd(day,Cast(@Join_Days as numeric),@Joining_Date)
		if @Display_Joinining =1 and @FlagEss = 1
		Begin

				set @FlagVal = 1
			   if @Current_Date <= @New_Join_Days and @Current_Date >= @Joining_Date 
		       Begin 

					if not exists(select Emp_doc_ID from V0090_EMP_HR_DOC_Detail where accepeted_status <>'Pending' and --accepted_date>=@from_date  and  and accepted_date<=@to_date
		        		Emp_id=@emp_id and HR_DOC_ID = @HR_DOC_ID and doc_title like (select doc_title from T0040_HR_DOC_MASTER WITH (NOLOCK) Where Cmp_ID = @Cmp_ID 
		        		and (isnull(gender,'M')='A' OR isnull(gender,'M')=@gender) and isnull(Display_Joinining,0)= @Display_Joinining and (HR_DOC_ID = @HR_DOC_ID or @HR_DOC_ID = 0)
		        		and(Branch_id is null or isnull(Branch_ID,0) = isnull(@Branch_ID ,isnull(Branch_ID,0)))
		        		and(Grd_id is null or isnull(Grd_ID,0) = isnull(@Grd_ID ,isnull(Grd_ID,0)) or isnull(@Grd_ID,0)=0)
		        		and (Dept_id is null or isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))or isnull(@Dept_ID,0)=0)
		        		and (Desig_ID is null or Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0)) or isnull(@Desig_ID,0)=0))
		        		)
		        		begin 		
		        				
		        				select top 1 * from T0040_HR_DOC_MASTER WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and gender = @flaggender and
		        				--(isnull(gender,'M')='A' OR isnull(gender,'M')=@gender) and 
		        				isnull(Display_Joinining,0)=CASE WHEN isnull(Display_Joinining,0) = 0 THEN isnull(Display_Joinining,0) ELSE @Display_Joinining END and (HR_DOC_ID = @HR_DOC_ID or @HR_DOC_ID = 0)
		        				and (Branch_id is null or isnull(Branch_ID,0) = isnull(@Branch_ID ,isnull(Branch_ID,0)) or isnull(Branch_ID,0) = 0)
		        				and (Grd_id is null or isnull(Grd_ID,0) = isnull(@Grd_ID ,isnull(Grd_ID,0)) or isnull(Grd_ID,0) = 0)
		        				and (Dept_id is null or isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))or isnull(Dept_ID,0) = 0)
		        				and (Desig_ID is null or Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0)) or isnull(Desig_ID,0) = 0)				
		        				order by HR_DOC_ID desc
		        				set @status =0
		        				
						end
				End
		       else
		       begin
			    			SELECT @status=accetpeted FROM V0090_EMP_HR_DOC_Detail where accepted_date>=@from_date and accepted_date<=@to_date and Emp_id=@emp_id and doc_title like (select doc_title from T0040_HR_DOC_MASTER WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and gender='' and 
		        				(isnull(gender,'M')='A' OR isnull(gender,'M')=@gender) and isnull(Display_Joinining,0)=@Display_Joinining and (isnull(Branch_ID,0) = isnull(@Branch_ID ,isnull(Branch_ID,0)) or isnull(branch_id,0)=0)and (isnull(Grd_ID,0) = isnull(@Grd_ID ,isnull(Grd_ID,0)) or isnull(Grd_ID,0)=0)and (isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0)) or isnull(@Dept_ID,0)=0)and (Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0)) or isnull(Desig_ID,0)=0))
		        			   
		        				IF @status = 1
		        				 BEGIN
		        					SET @emp_id=0
		        					RETURN
		        				 END
		        			   select * from V0090_EMP_HR_DOC_Detail where accepted_date>=@from_date and accepted_date<=@to_date and Emp_id=@emp_id and 
		        			   doc_title like(select doc_title from T0040_HR_DOC_MASTER WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and gender='' and (isnull(gender,'M')='A' OR isnull(gender,'M')=@gender) and 
		        			   isnull(Display_Joinining,0)=@Display_Joinining and (isnull(Branch_ID,0) = isnull(@Branch_ID ,isnull(Branch_ID,0)) or isnull(branch_id,0)=0)and (isnull(Grd_ID,0) = isnull(@Grd_ID ,isnull(Grd_ID,0)) or isnull(Grd_ID,0)=0)and (isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0)) or isnull(@Dept_ID,0)=0)and (Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0)) or isnull(Desig_ID,0)=0))
		        			   set @status = 1
 		       end	
		End
	End
		-- print 'www'
	 --return
	--select Emp_id from T0080_EMP_MASTER WITH (NOLOCK) where Cmp_ID = @Cmp_ID
	
	if @type= 0 
	begin
		if @HR_DOC_ID = 0 and @FlagEss = 1 
		begin 
				If Exists(Select Emp_doc_ID From T0090_EMP_HR_DOC_Detail  WITH (NOLOCK) Where Emp_id = @Emp_id and HR_DOC_ID = @HR_DOC_ID and accepted_date>=@for_date and accepted_date<=@todate and isnull(TYPE,0)=@type )
					 begin					
						Select * From T0090_EMP_HR_DOC_Detail  WITH (NOLOCK) Where Emp_id = @Emp_id and HR_DOC_ID = @HR_DOC_ID and accepted_date>=@for_date and accepted_date<=@todate and isnull(TYPE,0)=@type
					 end
				else
					begin
						select *,cast(getdate() as varchar(11)) as Curr_Date,@company_name as cmp_name from T0040_HR_DOC_MASTER WITH (NOLOCK) 
						where  Cmp_ID = @Cmp_ID and HR_DOC_ID=@HR_DOC_ID
						
						select Branch_name,Alpha_Emp_Code,grd_name,dept_name,desig_name,emp_full_name,cast(date_of_join as varchar(11)) as date_of_join,emp_full_name_superior,
						--basic_salary,gross_salary, --commented By Mukti(29062016)becoz in next increment query already used
						emp_left_date as left_date, --Mukti(31052016)
						other_email,work_email,street_1,state,city,zip_code,mobile_no,home_tel_no,cast(getdate() as varchar(11)) as Curr_Date,cmp_name
						from v0080_employee_master where emp_id=@emp_id
						
						--select top 1  basic_salary,increment_effective_date,Branch_name,grd_name from v0095_increment  --commented by Mukti(11032016)
						--where emp_id=@emp_id 
						--order by increment_effective_date
						
						--Mukti start(11032016)
						select  i.basic_salary,i.gross_salary,increment_effective_date,Branch_name,gm.grd_name,i.Branch_ID,
						case when ISNULL(em.Probation,0)=0 then gs.Probation else em.Probation end as Probation_Period,
						case when ISNULL(em.Emp_Notice_Period,0) > 0 then em.Emp_Notice_Period
						when ISNULL(gs.Is_Shortfall_Gradewise,0)=0 then gs.Short_Fall_Days
						else gm.Short_Fall_Days end as Notice_Period,
						DM.Desig_Name as Promoted_Designation,i.Pre_Basic_Salary as Prev_Basic_Salary,i.Pre_Gross_Salary as Prev_Gross_Salary, --Mukti(25062016)
						i.Increment_Amount
						FROM T0095_INCREMENT I WITH (NOLOCK)  --v0095_increment i commented by sneha on 29/11/2017 as it didnt bring the new joinees details
						INNER JOIN (
										SELECT MAX(Increment_ID)Increment_ID,T0095_INCREMENT.Emp_ID
										FROM T0095_INCREMENT WITH (NOLOCK)
										INNER JOIN (
														SELECT max(Increment_Effective_Date)Increment_Effective_Date,Emp_ID
														FROM T0095_INCREMENT WITH (NOLOCK)
														WHERE Increment_Effective_Date <= @from_date
														GROUP BY T0095_INCREMENT.Emp_ID
													)I3 ON I3.Emp_ID = T0095_INCREMENT.Emp_ID
										GROUP BY T0095_INCREMENT.Emp_ID
									)I1 ON I1.Increment_ID = I.Increment_ID AND I1.Emp_ID = I.Emp_ID
						inner join T0080_EMP_MASTER em WITH (NOLOCK) on em.Emp_ID=i.Emp_ID and em.Cmp_ID=i.Cmp_ID
						left join T0040_GENERAL_SETTING gs WITH (NOLOCK) on gs.Cmp_ID=i.Cmp_id and i.Branch_ID=gs.Branch_ID --Mukti(11032016) 
						INNER JOIN (
										SELECT max(Gen_ID)Gen_ID,T0040_GENERAL_SETTING.Branch_ID
										FROM T0040_GENERAL_SETTING WITH (NOLOCK)
										INNER JOIN (
														SELECT max(For_Date)For_Date,Branch_ID
														from T0040_GENERAL_SETTING WITH (NOLOCK)
														WHERE For_Date <= @from_date
														GROUP BY Branch_ID
													)GS2 ON GS2.Branch_ID = T0040_GENERAL_SETTING.Branch_ID
										GROUP BY T0040_GENERAL_SETTING.Branch_ID
									)GS1 ON GS1.Gen_ID = gs.Gen_ID AND gs.Branch_ID = gs1.Branch_ID
						left join T0040_GRADE_MASTER gm WITH (NOLOCK) on gm.Cmp_ID=i.Cmp_id and i.Grd_ID=gm.Grd_ID  --Mukti(11032016)
						left join T0040_DESIGNATION_MASTER DM WITH (NOLOCK) on DM.Cmp_ID=i.Cmp_id and i.Desig_Id=DM.Desig_ID --Mukti(25062016) 
						LEFT JOIN T0030_BRANCH_MASTER B WITH (NOLOCK) on b.Branch_ID = i.Branch_ID
						where i.emp_id=@emp_id --AND i.increment_id =(SELECT MAX (increment_id) FROM  T0095_INCREMENT 
						--where Emp_ID = @emp_id and Cmp_ID=@cmp_id and Increment_Effective_Date <= @from_date)  
						--and Increment_Effective_Date <=@to_date --commented By Mukti(29062016)
						order by increment_effective_date
						--Mukti end(11032016)
						
						SELECT @monthly_ctc=CTC FROM T0095_INCREMENT WITH (NOLOCK)						
						WHERE increment_id =(SELECT MAX (increment_id) FROM  T0095_INCREMENT WITH (NOLOCK) where Emp_ID = @emp_id and Cmp_ID=@Cmp_ID and Increment_Effective_Date <= @from_date)  --added by sneha for monthly CTC on 29-may-2012
						
						set @annual_ctc = @monthly_ctc * 12
						select isnull(@monthly_ctc,0) as CTC , isnull(@annual_ctc,0) as Annual_CTC
						select left_date,reg_accept_date,left_reason from t0100_LEFT_EMP WITH (NOLOCK)  where emp_id=@emp_id
						exec SP_RPT_EMP_OFFER_SALARY_GET @Cmp_ID=@Cmp_ID,@From_Date=@from_date,@To_Date=@to_date,@Branch_ID=0,@Cat_ID=0,@Grd_ID=0,@Type_ID=0,@Dept_ID=0,@Desig_ID=0,@Emp_ID=@emp_id,@Constraint=@emp_id ,@PBranch_ID='0'
					end
			  return
		end
	/*if  not exists(select branch_id,grd_id,dept_id,desig_id,(case when initial='Mr.' then 'M' else 'F' end) from v0080_employee_master where emp_id=@emp_id and date_of_join<=@from_date and dateadd(dd,30,date_of_join)>=@to_date)
	 begin
		set @status =1
	 end*/
		if @Display_Joinining =1
		 begin
			if exists(select left_date,reg_accept_date,left_reason from t0100_LEFT_EMP WITH (NOLOCK)  where emp_id=@emp_id)
			 begin
			   set @emp_id=0
			   return
			 end
		 end
		select @Branch_ID=branch_id,@Grd_ID=grd_id,@Dept_ID=dept_id,@Desig_ID=desig_id,@gender=(case when initial='Mr.' then 'M' else 'F' end) 
		from V0080_EMP_MASTER_INCREMENT_GET where emp_id=@emp_id
	
		--select @Branch_ID,@Grd_ID,@Desig_ID,@Dept_ID
		--select top 1 @HR_DOC_ID = HR_DOC_ID from T0040_HR_DOC_MASTER where Cmp_id = @Cmp_ID order by HR_DOC_ID desc
	
		if @FlagEss = 1 and @FlagVal = 0
		Begin
				if not exists(select Emp_doc_ID from V0090_EMP_HR_DOC_Detail where accepeted_status <>'Pending' and --accepted_date>=@from_date  and  and accepted_date<=@to_date
				Emp_id=@emp_id and HR_DOC_ID = @HR_DOC_ID and doc_title like (select doc_title from T0040_HR_DOC_MASTER WITH (NOLOCK) Where Cmp_ID = @Cmp_ID 
				and (isnull(gender,'M')='A' OR isnull(gender,'M')=@gender) and isnull(Display_Joinining,0)= @Display_Joinining and (HR_DOC_ID = @HR_DOC_ID or @HR_DOC_ID = 0)
				and(Branch_id is null or isnull(Branch_ID,0) = isnull(@Branch_ID ,isnull(Branch_ID,0)))
				and(Grd_id is null or isnull(Grd_ID,0) = isnull(@Grd_ID ,isnull(Grd_ID,0)) or isnull(@Grd_ID,0)=0)
				and (Dept_id is null or isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))or isnull(@Dept_ID,0)=0)
				and (Desig_ID is null or Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0)) or isnull(@Desig_ID,0)=0))
				)
				begin 		
						select top 1 * from T0040_HR_DOC_MASTER WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and 
						(isnull(gender,'M')='A' OR isnull(gender,'M')=@gender) and 
						isnull(Display_Joinining,0)=CASE WHEN isnull(Display_Joinining,0) = 0 THEN isnull(Display_Joinining,0) ELSE @Display_Joinining END and (HR_DOC_ID = @HR_DOC_ID or @HR_DOC_ID = 0)
						and (Branch_id is null or isnull(Branch_ID,0) = isnull(@Branch_ID ,isnull(Branch_ID,0)) or isnull(Branch_ID,0) = 0)
						and (Grd_id is null or isnull(Grd_ID,0) = isnull(@Grd_ID ,isnull(Grd_ID,0)) or isnull(Grd_ID,0) = 0)
						and (Dept_id is null or isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))or isnull(Dept_ID,0) = 0)
						and (Desig_ID is null or Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0)) or isnull(Desig_ID,0) = 0)				
						order by HR_DOC_ID desc
						set @status =0
						
				end
				else
				begin
						SELECT @status=accetpeted FROM V0090_EMP_HR_DOC_Detail where accepted_date>=@from_date and accepted_date<=@to_date and Emp_id=@emp_id and doc_title like (select doc_title from T0040_HR_DOC_MASTER WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and gender='' and 
						(isnull(gender,'M')='A' OR isnull(gender,'M')=@gender) and isnull(Display_Joinining,0)=@Display_Joinining and (isnull(Branch_ID,0) = isnull(@Branch_ID ,isnull(Branch_ID,0)) or isnull(branch_id,0)=0)and (isnull(Grd_ID,0) = isnull(@Grd_ID ,isnull(Grd_ID,0)) or isnull(Grd_ID,0)=0)and (isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0)) or isnull(@Dept_ID,0)=0)and (Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0)) or isnull(Desig_ID,0)=0))
						IF @status = 1
						 BEGIN
							SET @emp_id=0
							RETURN
						 END
					   select * from V0090_EMP_HR_DOC_Detail where accepted_date>=@from_date and accepted_date<=@to_date and Emp_id=@emp_id and 
					   doc_title like(select doc_title from T0040_HR_DOC_MASTER WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and gender='' and (isnull(gender,'M')='A' OR isnull(gender,'M')=@gender) and 
					   isnull(Display_Joinining,0)=@Display_Joinining and (isnull(Branch_ID,0) = isnull(@Branch_ID ,isnull(Branch_ID,0)) or isnull(branch_id,0)=0)and (isnull(Grd_ID,0) = isnull(@Grd_ID ,isnull(Grd_ID,0)) or isnull(Grd_ID,0)=0)and (isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0)) or isnull(@Dept_ID,0)=0)and (Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0)) or isnull(Desig_ID,0)=0))
					   set @status = 1
 				end
		End
		
		if @FlagEss <> 1 or @FlagVal = 1
		Begin
			set @status = 0
		End
	
		if isnull(@status,0)<>1 
		 begin
			SELECT cast(getdate() as varchar(11)) as Curr_Date,cmp_name from t0010_company_master WITH (NOLOCK) where cmp_id=@cmp_id
			SELECT Branch_name,Alpha_Emp_Code,grd_name,dept_name,desig_name,emp_full_name,cast(date_of_join as varchar(11)) as date_of_join,basic_salary,gross_salary,emp_full_name_superior,emp_left_date,other_email,work_email,street_1,state,city,zip_code,mobile_no,home_tel_no,cast(getdate() as varchar(11)) as Curr_Date,cmp_name from v0080_employee_master where emp_id=@emp_id
			SELECT TOP 1 basic_salary,gross_salary,increment_effective_date,Branch_name,grd_name from v0095_increment where emp_id=@emp_id order by increment_effective_date
				SELECT @monthly_ctc=CTC FROM T0095_INCREMENT WITH (NOLOCK) WHERE increment_id =(SELECT MAX (increment_id) FROM  T0095_INCREMENT WITH (NOLOCK) where Emp_ID = @emp_id and Cmp_ID=@Cmp_ID) --added by sneha for monthly CTC on 29-may-2012
				SET @annual_ctc = @monthly_ctc * 12
			SELECT isnull(@monthly_ctc,0) as CTC , isnull(@annual_ctc,0) as Annual_CTC
			SELECT left_date,reg_accept_date,left_reason from t0100_LEFT_EMP WITH (NOLOCK)  where emp_id=@emp_id
			exec SP_RPT_EMP_OFFER_SALARY_GET @Cmp_ID=@Cmp_ID,@From_Date=@from_date,@To_Date=@to_date,@Branch_ID=0,@Cat_ID=0,@Grd_ID=0,@Type_ID=0,@Dept_ID=0,@Desig_ID=0,@Emp_ID=@emp_id,@Constraint=@emp_id ,@PBranch_ID='0'
	  	end
	end
else
	begin
	--print '1111'
			declare @temp_Date as Datetime
			set @temp_Date = GETDATE()
				if @HR_DOC_ID <> 0
					 begin
						If Exists(Select Emp_doc_ID From T0090_EMP_HR_DOC_Detail WITH (NOLOCK)  Where Emp_id = @Emp_id and HR_DOC_ID = @HR_DOC_ID and accepted_date>=@for_date and accepted_date<=@todate and isnull(TYPE,0)=@type)
							 begin
							 --print '222'
							 select 1 as res
			
								Select * From T0090_EMP_HR_DOC_Detail WITH (NOLOCK) Where Emp_id = @Emp_id and HR_DOC_ID = @HR_DOC_ID and accepted_date>=@for_date and accepted_date<=@todate and isnull(TYPE,0)=@type
							 end
						else
							begin
							--print '333'
							select *,@for_date as Curr_Date,@company_name as cmp_name from T0040_HR_DOC_MASTER WITH (NOLOCK) where  Cmp_ID = @Cmp_ID and HR_DOC_ID=@HR_DOC_ID

								if exists(select 1 from V0060_HRMS_Candidates_Finalization where Resume_ID=@emp_id )
									begin 
											--print '444'
										--select Branch_name,Alpha_Emp_Code,grd_name,dept_name,desig_name,emp_full_name,cast(date_of_join as varchar(11)) as date_of_join,basic_salary,gross_salary,emp_full_name_superior,emp_left_date,other_email,work_email,street_1,state,city,zip_code,mobile_no,home_tel_no,cast(getdate() as varchar(11)) as Curr_Date,cmp_name from v0080_employee_master where emp_id=@emp_id
										select Branch_name,resume_code as Alpha_Emp_Code,grd_name,dept_name,desig_name,V0060_HRMS_Candidates_Finalization.app_full_name as emp_full_name,
										cast(date_of_join as varchar(11)) as date_of_join,Basic_Salay as basic_salary,total_ctc as gross_salary,Emp_full_name as emp_full_name_superior,'' as emp_left_date, '' as other_email,work_email,Permanent_Street as street_1,
										Permanent_State as state,Permanent_City as city,Permanentt_Post_Box as zip_code,mobile_no,home_tel_no,cast(getdate() as varchar(11)) as Curr_Date,cmp_name 
										from V0060_HRMS_Candidates_Finalization where Resume_ID=@emp_id
									end
								else
									begin  
											--print '555'
										select '' as Branch_name,resume_code as Alpha_Emp_Code,'' as grd_name,'' as dept_name,'' as desig_name,V0055_HRMS_RESUME_MASTER.App_Full_name as emp_full_name,
										'' as date_of_join,0 as basic_salary,0 as gross_salary,'' as emp_full_name_superior,'' as emp_left_date, '' as other_email,Primary_email,Permanent_Street as street_1,
										Permanent_State as state,Permanent_City as city,Permanentt_Post_Box as zip_code,mobile_no,home_tel_no,cast(getdate() as varchar(11)) as Curr_Date--,cmp_name 
										from V0055_HRMS_RESUME_MASTER 
										where Resume_ID=@emp_id
									end
								--select top 1  basic_salary,increment_effective_date,Branch_name,grd_name from v0095_increment where emp_id=@emp_id order by increment_effective_date
								select Basic_Salay as basic_salary,cast(date_of_join as varchar(11)) as increment_effective_date,Branch_name,grd_name from V0060_HRMS_Candidates_Finalization where Resume_ID=@emp_id
								
									--SELECT @monthly_ctc=CTC FROM T0095_INCREMENT WHERE increment_id =(SELECT MAX (increment_id) FROM  T0095_INCREMENT where Emp_ID = @emp_id and Cmp_ID=@Cmp_ID) --added by sneha for monthly CTC on 29-may-2012
									--set @annual_ctc = @monthly_ctc * 12
								--select isnull(@monthly_ctc,0) as CTC , isnull(@annual_ctc,0) as Annual_CTC
								select total_ctc as CTC,(Total_CTC*12) as Annual_CTC from V0060_HRMS_Candidates_Finalization where Resume_ID=@emp_id
								--select left_date,reg_accept_date,left_reason from t0100_LEFT_EMP  where emp_id=@emp_id
								select 'left_date' as left_date,'reg_accept_date' as reg_accept_date,'left_reason' as left_reason
								exec SP_RPT_EMP_OFFER_SALARY_GET_Candidate @Cmp_ID=@Cmp_ID,@From_Date=@temp_Date,@To_Date=@temp_Date,@Branch_ID=0,@Cat_ID=0,@Grd_ID=0,@Type_ID=0,@Dept_ID=0,@Desig_ID=0,@Emp_ID=@emp_id,@Constraint=@emp_id ,@PBranch_ID='0'
							end
					  return
					 end
			/*if  not exists(select branch_id,grd_id,dept_id,desig_id,(case when initial='Mr.' then 'M' else 'F' end) from v0080_employee_master where emp_id=@emp_id and date_of_join<=@from_date and dateadd(dd,30,date_of_join)>=@to_date)
			 begin
				set @status =1
			 end*/
			--if @Display_Joinining =1
			-- begin
			--	if exists(select left_date,reg_accept_date,left_reason from t0100_LEFT_EMP  where emp_id=@emp_id)
			--	 begin
			--	   set @emp_id=0
			--		print('here1')
			--	   return
			--	 end
			-- end
			select @Branch_ID=branch_id,@Grd_ID=grd_id,@Dept_ID=dept_id,@Desig_ID=desig_id,@gender=(case when initial='Mr.' then 'M' else 'F' end) from V0060_HRMS_Candidates_Finalization where Resume_ID=@emp_id
			
			if not exists(select Emp_doc_ID from V0090_EMP_HR_DOC_Detail_Candidate where accepted_date>=@from_date and Emp_id=@emp_id and isnull(type,0)=@type and doc_title like (select doc_title from T0040_HR_DOC_MASTER WITH (NOLOCK) Where Cmp_ID = @Cmp_ID 
			and (isnull(gender,'M')='A' OR isnull(gender,'M')=@gender) and isnull(Display_Joinining,0)=@Display_Joinining  
			--(isnull(Branch_ID,0) = isnull(@Branch_ID ,isnull(Branch_ID,0)) or isnull(branch_id,0)=0)
			--and (isnull(Grd_ID,0) = isnull(@Grd_ID ,isnull(Grd_ID,0)) or isnull(Grd_ID,0)=0)
			--and (isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0)) or isnull(@Dept_ID,0)=0)
			--and (Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0)) or isnull(Desig_ID,0)=0)) 
			))
				begin
				
						select * from T0040_HR_DOC_MASTER WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and (isnull(gender,'M')='A' OR isnull(gender,'M')=@gender) and isnull(Display_Joinining,0)=@Display_Joinining
						and (isnull(Branch_ID,0) = isnull(@Branch_ID ,isnull(Branch_ID,0)) or isnull(Branch_ID,0) = 0)
						and (isnull(Grd_ID,0) = isnull(@Grd_ID ,isnull(Grd_ID,0)) or isnull(Grd_ID,0) = 0)
						and (isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))or isnull(Dept_ID,0) = 0)
						and (Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0)) or isnull(Desig_ID,0) = 0)
						set @status =0
				end
			else
			   begin
			  
			   		select @status=accetpeted from V0090_EMP_HR_DOC_Detail_Candidate where accepted_date>=@from_date and accepted_date<=@to_date and Emp_id=@emp_id and doc_title like (select doc_title from T0040_HR_DOC_MASTER WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and (isnull(gender,'M')='A' OR isnull(gender,'M')=@gender) and isnull(Display_Joinining,0)=@Display_Joinining and (isnull(Branch_ID,0) = isnull(@Branch_ID ,isnull(Branch_ID,0)) or isnull(branch_id,0)=0)and (isnull(Grd_ID,0) = isnull(@Grd_ID ,isnull(Grd_ID,0)) or isnull(Grd_ID,0)=0)and (isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0)) or isnull(@Dept_ID,0)=0)and (Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0)) or isnull(Desig_ID,0)=0)) 
				   
					if @status = 1
					 begin
						set @emp_id=0
						return
					 end
				   select * from V0090_EMP_HR_DOC_Detail where accepted_date>=@from_date and accepted_date<=@to_date and Emp_id=@emp_id and isnull(type,0)= @type and doc_title like(select doc_title from T0040_HR_DOC_MASTER WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and gender='' and gender=@gender and isnull(Display_Joinining,0)=@Display_Joinining and (isnull(Branch_ID,0) = isnull(@Branch_ID ,isnull(Branch_ID,0)) or isnull(branch_id,0)=0)and (isnull(Grd_ID,0) = isnull(@Grd_ID ,isnull(Grd_ID,0)) or isnull(Grd_ID,0)=0)and (isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0)) or isnull(@Dept_ID,0)=0)and (Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0)) or isnull(Desig_ID,0)=0)) 
				   set @status = 1
 			  end
 			  
			if isnull(@status,0)<>1
			 begin
				select cast(getdate() as varchar(11)) as Curr_Date,cmp_name from t0010_company_master WITH (NOLOCK) where cmp_id=@cmp_id
				--select Branch_name,Alpha_Emp_Code,grd_name,dept_name,desig_name,emp_full_name,cast(date_of_join as varchar(11)) as date_of_join,basic_salary,gross_salary,emp_full_name_superior,emp_left_date,other_email,work_email,street_1,state,city,zip_code,mobile_no,home_tel_no,cast(getdate() as varchar(11)) as Curr_Date,cmp_name from v0080_employee_master where emp_id=@emp_id
				select Branch_name,resume_code as Alpha_Emp_Code,grd_name,dept_name,desig_name,V0060_HRMS_Candidates_Finalization.app_full_name as emp_full_name,
					cast(date_of_join as varchar(11)) as date_of_join,Basic_Salay as basic_salary,total_ctc as gross_salary,Emp_full_name as emp_full_name_superior,'' as emp_left_date, '' as other_email,work_email,Permanent_Street as street_1,
					Permanent_State as state,Permanent_City as city,Permanentt_Post_Box as zip_code,mobile_no,home_tel_no,cast(getdate() as varchar(11)) as Curr_Date,cmp_name 
					from V0060_HRMS_Candidates_Finalization where Resume_ID=@emp_id
				
				--select top 1 basic_salary,gross_salary,increment_effective_date,Branch_name,grd_name from v0095_increment where emp_id=@emp_id order by increment_effective_date
					select Basic_Salay as basic_salary,cast(date_of_join as varchar(11)) as increment_effective_date,Branch_name,grd_name from V0060_HRMS_Candidates_Finalization where Resume_ID=@emp_id
				
					--SELECT @monthly_ctc=CTC FROM T0095_INCREMENT WHERE increment_id =(SELECT MAX (increment_id) FROM  T0095_INCREMENT where Emp_ID = @emp_id and Cmp_ID=@Cmp_ID) --added by sneha for monthly CTC on 29-may-2012
					--set @annual_ctc = @monthly_ctc * 12
				--select isnull(@monthly_ctc,0) as CTC , isnull(@annual_ctc,0) as Annual_CTC
				select total_ctc as CTC,(Total_CTC*12) as Annual_CTC from V0060_HRMS_Candidates_Finalization where Resume_ID=@emp_id
				
				--select left_date,reg_accept_date,left_reason from t0100_LEFT_EMP  where emp_id=@emp_id
				select 'left_date' as left_date, 'reg_accept_date' as reg_accept_date,'left_reason' as left_reason 
				
				exec SP_RPT_EMP_OFFER_SALARY_GET_Candidate @Cmp_ID=@Cmp_ID,@From_Date=@temp_Date,@To_Date=@temp_Date,@Branch_ID=0,@Cat_ID=0,@Grd_ID=0,@Type_ID=0,@Dept_ID=0,@Desig_ID=0,@Emp_ID=@emp_id,@Constraint=@emp_id ,@PBranch_ID='0'
			end
	end


