CREATE PROCEDURE [dbo].[Exit_Appoval_Details]  
 @CMP_ID  NUMERIC ,  
 @EMP_ID  NUMERIC ,  
 @FOR_DATE DATETIME = null ,  
 @Leave_Application numeric(18,0) = 0, 
 @Leave_Encash_App_ID numeric(18,0) = 0,
 @Leave_ID	Numeric(18,0) = 0, --Added by Nimesh on 26-Nov-2015 (To get only particular leave balance),
 @Return_Table Numeric(18,2)=0,  --Added by Jaina 23-06-2017 (For SLS, Get leave detail in table format)
 @to_date DATE,
 @fromdate DATE
AS  
 SET NOCOUNT ON    
	
    Declare @Comp_Off_Date as datetime
   	declare @branch_id as numeric
   	declare @GRD_ID  NUMERIC 
	declare	@from_date as datetime
	Declare @Is_Compoff as int
	declare @comp_off_leave_id  as numeric
	Declare @COPH_leave_id as numeric
	Declare @COND_Leave_ID as numeric	
	set @COPH_leave_id = 0
	set @COND_Leave_ID = 0 --Added by Sumit 29092016
	
	set @comp_off_leave_id = 0
	Set @Is_Compoff = 0
	
	IF @Leave_ID = 0
		SET @Leave_ID = NULL;
	
	 create table #temp_CompOff
		(
			Leave_opening	decimal(18,2),
			Leave_Used		decimal(18,2),
			Leave_Closing	decimal(18,2),
			Leave_Code		varchar(max),
			Leave_Name		varchar(max),
			Leave_ID		numeric,
			CompOff_String  varchar(max) default null -- Added by Gadriwala 18022015
		)
	create table #temp_COPH  -- 
			(
				Leave_opening	decimal(18,2),
				Leave_Used		decimal(18,2),
				Leave_Closing	decimal(18,2),
				Leave_Code		varchar(max),
				Leave_Name		varchar(max),
				Leave_ID		numeric,
				COPH_String  varchar(max) default null -- 
		)	
	 create table #temp_COND  -- Sumit 29092016
			(
				Leave_opening	decimal(18,2),
				Leave_Used		decimal(18,2),
				Leave_Closing	decimal(18,2),
				Leave_Code		varchar(max),
				Leave_Name		varchar(max),
				Leave_ID		numeric,
				COND_String  varchar(max) default null 
		)	

	if ISNULL(@For_Date,'') = ''
		begin
			select @Comp_Off_Date = max(For_Date) From T0140_LEAVE_TRANSACTION WITH (NOLOCK)  where Emp_ID = @Emp_ID  and Cmp_ID = @CMP_ID
		end
	else
		begin
			set @Comp_Off_Date = @FOR_DATE
		end

   select @For_Date = ISNULL(MAX(FOR_DATE),GETDATE()) From T0140_LEAVE_TRANSACTION WITH (NOLOCK)   where Emp_ID = @Emp_ID  and Cmp_ID = @CMP_ID
    
			select @branch_id = branch_id,@GRD_ID = grd_id from T0095_INCREMENT  INC  WITH (NOLOCK) INNER JOIN 
					(
						SELECT	MAX(I2.Increment_ID) AS Increment_ID,I2.Emp_ID 	
						FROM	T0095_Increment I2  WITH (NOLOCK) INNER JOIN 
								T0080_EMP_MASTER E  WITH (NOLOCK) ON I2.Emp_ID=E.Emp_ID INNER JOIN 
								(
									SELECT	MAX(INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I3.EMP_ID	
									FROM	T0095_INCREMENT I3  WITH (NOLOCK) INNER JOIN 
											T0080_EMP_MASTER E3  WITH (NOLOCK) ON I3.Emp_ID=E3.Emp_ID 
									WHERE	I3.Increment_effective_Date <= @For_Date AND I3.Cmp_ID = @Cmp_ID	
									GROUP BY I3.EMP_ID 
								 ) I3 ON I2.Increment_Effective_Date=I3.Increment_Effective_Date AND I2.EMP_ID=I3.Emp_ID	
						GROUP BY I2.Emp_ID 
					) I ON INC.Emp_ID = I.Emp_ID AND INC.Increment_ID = I.Increment_ID
			where INc.Emp_ID = @Emp_ID 

			
			--Changed By Jimit 19042019 as branch id is not latest (DNPL)
			--where Emp_ID = @Emp_ID and Increment_ID = 
			--(
			--	select MAX(Increment_ID) from T0095_INCREMENT 
			--	where Emp_ID = @Emp_ID and Cmp_ID  =@CMP_ID and Increment_Effective_Date<=@For_Date
			--)
	
	
	select @comp_off_leave_id = leave_id from T0040_LEAVE_MASTER WITH (NOLOCK) 
		where isnull(Default_Short_Name,'') = 'COMP' and Cmp_ID = @CMP_ID
		
	---Added by Sumit 29092016------------------------------------------------------		
	select @COPH_leave_id = leave_id from T0040_LEAVE_MASTER  WITH (NOLOCK) 
		where isnull(Default_Short_Name,'') = 'COPH' and Cmp_ID = @CMP_ID
	
	select @COND_Leave_ID = Leave_ID from T0040_LEAVE_MASTER 
	where ISNULL(Default_Short_Name,'') = 'COND' and Cmp_ID = @CMP_ID	
	-------------------------------------------------------------------------		
		
	select @Is_Compoff = Isnull(Is_CompOff,0) from T0040_GENERAL_SETTING  WITH (NOLOCK) 
		Where For_Date = (
							Select Max(For_Date) From T0040_GENERAL_SETTING  WITH (NOLOCK) 
							Where Branch_ID = @branch_id and cmp_ID = @cmp_ID
						) And Branch_ID = @branch_id
	
	--select @Comp_Off_Date,@emp_id,@cmp_id,@comp_off_leave_id,@Leave_Application,@Leave_Encash_App_ID
	
	If @Is_Compoff = 1 
		
			exec GET_COMPOFF_DETAILS @For_Date =@Comp_Off_Date,@Emp_ID = @emp_id,@Cmp_ID = @cmp_id,@leave_ID = @comp_off_leave_id,@Leave_Application_ID =@Leave_Application ,@Leave_Encash_App_ID = @Leave_Encash_App_ID,@Exec_For =1
			--Added by Sumit 29092016------------------------------------------
			exec GET_COPH_DETAILS @For_Date =@Comp_Off_Date,@Emp_ID = @emp_id,@Cmp_ID = @cmp_id,@leave_ID = @COPH_leave_id,@Leave_Application_ID =@Leave_Application ,@Exec_For =1
			exec Get_COND_Details @For_Date =@Comp_Off_Date,@Emp_ID = @emp_id,@Cmp_ID = @cmp_id,@leave_ID = @COND_leave_id,@Leave_Application_ID =@Leave_Application ,@Exec_For =1
    
    
  	--select @GRD_ID = grd_id From T0095_Increment I inner join     
			--	(
			--		  select max(Increment_Id) as Increment_Id , Emp_ID from T0095_Increment    
			--			where Increment_Effective_date <= @FOR_DATE group by emp_ID
			--	) Qry on  I.Emp_ID = Qry.Emp_ID and I.Increment_Id = Qry.Increment_Id Where I.Emp_ID = @Emp_ID
	
		--Added by Gadriwala Muslim 07072015
		
	Declare @Branch_Wise_Leave as tinyint
		set @Branch_Wise_Leave = 0
	
	select @Branch_Wise_Leave = Setting_Value from T0040_Setting  WITH (NOLOCK) where Cmp_ID = @cmp_ID and setting_Name = 'Branch wise Leave' 				
	
	
	IF OBJECT_ID('tempdb..#Leave_Detail') IS NULL 
	BEGIN			
		CREATE table #Leave_Detail
		(
			Leave_Opening numeric(18,2),
			Leave_Used numeric(18,2),
			Leave_Closing numeric(18,2),
			Leave_Code varchar(10),
			Leave_Name varchar(250),
			Leave_ID numeric(18,0),
			Leave_Type varchar(10)
		)
	END	
	
	if @Branch_Wise_Leave = 1  -- Changed For Branch wise Leave ( Gadriwala Muslim 07062015)
		begin
				
				Create Table #Leave_Name_Branch_Wise
					(
						Leave_ID numeric(18,0),
						Leave_Name nvarchar(250),
					)
					Insert into #Leave_Name_Branch_Wise
						Exec GET_Leave_Details @cmp_ID,@GRD_ID,@EMP_ID,@branch_id,'',@Leave_ID
					

		insert INTO #Leave_Detail
		SELECT DISTINCT
				LT.Leave_Opening, (LT.Leave_Used + ISNULL(Q1.Leave_Used,0)) AS Leave_Used, 
				dbo.f_lower_round((LT.Leave_Closing - ISNULL(Q1.leave_used,0)),LT.cmp_id) AS Leave_Closing,
				LM.Leave_Code, LM.Leave_Name, LT.Leave_ID,case when lm.Apply_Hourly = 1 then 'hour(s)' else 'day(s)'  end as Leave_Type  --Added by Gadriwala Muslim 15062015
		FROM	T0140_LEAVE_TRANSACTION AS LT WITH (NOLOCK) 
		INNER JOIN (SELECT	MAX(For_Date) AS FOR_DATE, Leave_ID, Emp_ID
					FROM	T0140_LEAVE_TRANSACTION WITH (NOLOCK) 
					WHERE	(Emp_ID = @EMP_ID) AND (For_Date <= @FOR_DATE) AND (Leave_ID IN (
															  SELECT Leave_ID FROM
															  V0040_LEAVE_DETAILS WHERE
															  (Grd_ID = @GRD_ID) AND (Display_leave_balance = 1)))
					GROUP BY Emp_ID, Leave_ID) AS Q ON LT.Emp_ID = Q.Emp_ID AND LT.Leave_ID = Q.Leave_ID 
					AND LT.For_Date = Q.FOR_DATE and isnull(LT.Leave_Posting,0)=0 --Added by Mukti(26042021) Leave_Posting=0
		LEFT OUTER JOIN (SELECT	Leave_ID, Emp_ID,SUM(Leave_Used) AS Leave_Used
					FROM	T0140_LEAVE_TRANSACTION WITH (NOLOCK) 
					WHERE	(Emp_ID = @EMP_ID) AND (For_Date > @FOR_DATE) AND (Leave_ID IN (
															  SELECT Leave_ID FROM
															  V0040_LEAVE_DETAILS WHERE
															  (Grd_ID = @GRD_ID) AND (Display_leave_balance = 1)))
					GROUP BY Emp_ID, Leave_ID) AS Q1 ON LT.Emp_ID = Q1.Emp_ID AND LT.Leave_ID = Q1.Leave_ID 
		INNER JOIN T0040_LEAVE_MASTER AS LM  WITH (NOLOCK) ON LT.Leave_ID = LM.Leave_ID and (1=(case isnull(leave_Status,0) when 0 then (case when isnull(InActive_Effective_Date,getdate())>getdate() then 1 else 0 end ) else  1 end ))
		Inner join #Leave_Name_Branch_Wise as LMBW ON LMBW.Leave_ID = LT.Leave_ID
		where lt.Leave_ID <> @comp_off_leave_id	and lt.Leave_ID <> @COPH_leave_id and lt.Leave_ID <> @COND_Leave_ID		
		union										
		select Leave_opening,Leave_used,
		Leave_Closing,#temp_CompOff.Leave_Code COLLATE SQL_Latin1_General_CP1_CI_AS,#temp_CompOff.Leave_Name COLLATE SQL_Latin1_General_CP1_CI_AS,#temp_CompOff.Leave_ID,case when T0040_LEAVE_MASTER.Apply_Hourly = 1 then 'hour(s)' else 'day(s)'  end as Leave_Type --Added by Gadriwala Muslim 15062015
		from #temp_CompOff inner join T0040_LEAVE_MASTER WITH (NOLOCK)  on 	#temp_CompOff.Leave_ID =	T0040_LEAVE_MASTER.Leave_ID 
		Inner join #Leave_Name_Branch_Wise as LMBW ON LMBW.Leave_ID = #temp_CompOff.Leave_ID
		where isnull(T0040_LEAVE_MASTER.Display_leave_balance ,0)=1 and cmp_Id = @cmp_ID
		union --Sumit on 29092016
		select Leave_opening,Leave_used,
		Leave_Closing,#temp_COPH.Leave_Code COLLATE SQL_Latin1_General_CP1_CI_AS,#temp_COPH.Leave_Name COLLATE SQL_Latin1_General_CP1_CI_AS,#temp_COPH.Leave_ID,case when T0040_LEAVE_MASTER.Apply_Hourly = 1 then 'hour(s)' else 'day(s)'  end as Leave_Type --Added by Gadriwala Muslim 15062015
		from #temp_COPH inner join T0040_LEAVE_MASTER WITH (NOLOCK)  on 	#temp_COPH.Leave_ID =	T0040_LEAVE_MASTER.Leave_ID 
		Inner join #Leave_Name_Branch_Wise as LMBW ON LMBW.Leave_ID = #temp_COPH.Leave_ID
		where isnull(T0040_LEAVE_MASTER.Display_leave_balance ,0)=1 and cmp_Id = @cmp_ID
		union
		select Leave_opening,Leave_used,
		Leave_Closing,#temp_COND.Leave_Code COLLATE SQL_Latin1_General_CP1_CI_AS,#temp_COND.Leave_Name COLLATE SQL_Latin1_General_CP1_CI_AS,#temp_COND.Leave_ID,case when T0040_LEAVE_MASTER.Apply_Hourly = 1 then 'hour(s)' else 'day(s)'  end as Leave_Type --Added by Gadriwala Muslim 15062015
		from #temp_COND inner join T0040_LEAVE_MASTER WITH (NOLOCK)  on 	#temp_COND.Leave_ID =	T0040_LEAVE_MASTER.Leave_ID 
		Inner join #Leave_Name_Branch_Wise as LMBW ON LMBW.Leave_ID = #temp_COND.Leave_ID
		where isnull(T0040_LEAVE_MASTER.Display_leave_balance ,0)=1 and cmp_Id = @cmp_ID

			--Added by Jaina 23-06-2017
			if @Return_Table = 0
			begin
				select * from #Leave_Detail
			end
		end
	else
		begin
		
		insert INTO #Leave_Detail	
		SELECT DISTINCT
				LT.Leave_Opening, (LT.Leave_Used + ISNULL(Q1.Leave_Used,0)) AS Leave_Used, 
				dbo.f_lower_round((LT.Leave_Closing - ISNULL(Q1.leave_used,0)),LT.cmp_id) AS Leave_Closing,
				LM.Leave_Code, LM.Leave_Name, LT.Leave_ID,case when lm.Apply_Hourly = 1 then 'hour(s)' else 'day(s)'  end as Leave_Type  --Added by Gadriwala Muslim 15062015
		FROM	T0140_LEAVE_TRANSACTION AS LT WITH (NOLOCK) 
		INNER JOIN (SELECT	MAX(For_Date) AS FOR_DATE, Leave_ID, Emp_ID
					FROM	T0140_LEAVE_TRANSACTION WITH (NOLOCK) 
					WHERE	(Emp_ID = @EMP_ID) AND (For_Date <= @FOR_DATE) AND (Leave_ID IN (
															  SELECT Leave_ID FROM
															  V0040_LEAVE_DETAILS WHERE
															  (Grd_ID = @GRD_ID) AND (Display_leave_balance = 1)))
					GROUP BY Emp_ID, Leave_ID) AS Q ON LT.Emp_ID = Q.Emp_ID AND LT.Leave_ID = Q.Leave_ID 
					AND LT.For_Date = Q.FOR_DATE
		LEFT OUTER JOIN (SELECT distinct Leave_ID, Emp_ID,SUM(Leave_Used) AS Leave_Used
					FROM	T0140_LEAVE_TRANSACTION WITH (NOLOCK) 
					WHERE	(Emp_ID = @EMP_ID) AND (For_Date > @FOR_DATE) AND (Leave_ID IN (
															  SELECT distinct Leave_ID FROM
															  V0040_LEAVE_DETAILS WHERE
															  (Grd_ID = @GRD_ID) AND (Display_leave_balance = 1)))
					GROUP BY Emp_ID, Leave_ID) AS Q1 ON LT.Emp_ID = Q1.Emp_ID AND LT.Leave_ID = Q1.Leave_ID 
		INNER JOIN T0040_LEAVE_MASTER AS LM  WITH (NOLOCK) ON LT.Leave_ID = LM.Leave_ID and (1=(case isnull(leave_Status,0) when 0 then (case when isnull(InActive_Effective_Date,getdate())>getdate() then 1 else 0 end ) else  1 end ))
		where lt.Leave_ID <> @comp_off_leave_id and lt.Leave_ID <> @COPH_leave_id and lt.Leave_ID <> @COND_Leave_ID
		union										
		select Leave_opening,Leave_used,
		Leave_Closing,#temp_CompOff.Leave_Code COLLATE SQL_Latin1_General_CP1_CI_AS,#temp_CompOff.Leave_Name COLLATE SQL_Latin1_General_CP1_CI_AS,#temp_CompOff.Leave_ID,case when T0040_LEAVE_MASTER.Apply_Hourly = 1 then 'hour(s)' else 'day(s)'  end as Leave_Type --Added by Gadriwala Muslim 15062015
		from #temp_CompOff inner join T0040_LEAVE_MASTER WITH (NOLOCK)  on 	#temp_CompOff.Leave_ID =	T0040_LEAVE_MASTER.Leave_ID where isnull(T0040_LEAVE_MASTER.Display_leave_balance ,0)=1 and cmp_ID = @cmp_ID
		union --Sumit on 29092016
		select Leave_opening,Leave_used,  
		Leave_Closing,#temp_COPH.Leave_Code COLLATE SQL_Latin1_General_CP1_CI_AS,#temp_COPH.Leave_Name COLLATE SQL_Latin1_General_CP1_CI_AS,#temp_COPH.Leave_ID,case when T0040_LEAVE_MASTER.Apply_Hourly = 1 then 'hour(s)' else 'day(s)'  end as Leave_Type --Added by Gadriwala Muslim 15062015
		from #temp_COPH inner join T0040_LEAVE_MASTER WITH (NOLOCK)  on 	#temp_COPH.Leave_ID =	T0040_LEAVE_MASTER.Leave_ID where isnull(T0040_LEAVE_MASTER.Display_leave_balance ,0)=1 and cmp_ID = @cmp_ID
		union
		select Leave_opening,Leave_used,  
		Leave_Closing,#temp_COND.Leave_Code COLLATE SQL_Latin1_General_CP1_CI_AS,#temp_COND.Leave_Name COLLATE SQL_Latin1_General_CP1_CI_AS,#temp_COND.Leave_ID,case when T0040_LEAVE_MASTER.Apply_Hourly = 1 then 'hour(s)' else 'day(s)'  end as Leave_Type --Added by Gadriwala Muslim 15062015
		from #temp_COND inner join T0040_LEAVE_MASTER  WITH (NOLOCK) on 	#temp_COND.Leave_ID =	T0040_LEAVE_MASTER.Leave_ID where isnull(T0040_LEAVE_MASTER.Display_leave_balance ,0)=1 and cmp_ID = @cmp_ID
		
			--Added by Jaina 23-06-2017
			if @Return_Table = 0
			begin
				select Leave_Name,Leave_Closing as Leave from #Leave_Detail
			end
		
		end

		
		select Asset_Name,Brand_Name,Vendor,Type_Of_Asset,Model_Name,Serial_No,Asset_Code,Emp_ID,Cmp_ID,Return_Date,Type,Allocation_Date from V0040_Asset_Allocation where Cmp_ID = @Cmp_ID and Emp_id =@EMP_ID order by Allocation_Date	
		
		select Loan_Name,Loan_Apr_Date,Loan_Apr_Amount,Loan_Apr_Pending_Amount,Loan_Apr_Status from V0120_LOAN_APPROVAL where Cmp_ID = @Cmp_ID and Emp_id =@Emp_ID order by loan_id	
			
		Select emp_id,resignation_date,status From T0200_Emp_ExitApplication Where cmp_id=@Cmp_ID and emp_id=@Emp_ID order by exit_id desc	

		select * from V0100_Warning_Details where Emp_id =@Emp_ID and cmp_id = @Cmp_ID
		
		exec P0200_AdvanceDetail_Exit @Cmp_ID=@Cmp_ID,@Todate=@to_date,@Emp_Id=@Emp_ID

		exec GET_LOAN_GUARANTOR_FOR_EXIT @Cmp_ID=@Cmp_ID,@To_Date=@fromdate ,@Branch_ID='0',@Cat_ID='0',@Grd_ID='0',@Type_ID='0',@Dept_ID='0',@Desig_ID='0',@Emp_ID=@Emp_ID,@Constraint=@Emp_ID	

 RETURN  
  
  
  

