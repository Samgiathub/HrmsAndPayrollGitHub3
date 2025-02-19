

CREATE PROCEDURE [dbo].[SP_RPT_EMP_LETTER_GET]
	 @Cmp_ID		numeric
	,@From_Date		datetime
	,@To_Date		datetime 
	,@Branch_ID		numeric   = 0
	,@Cat_ID		numeric  = 0
	,@Grd_ID		numeric = 0
	,@Type_ID		numeric  = 0
	,@Dept_ID		numeric  = 0
	,@Desig_ID		numeric = 0
	,@Emp_ID		numeric  = 0
	,@Constraint	varchar(MAX) = ''
	,@Letter		varchar(30)='Offer'
	,@PBranch_ID    numeric  = 0   --added jimit 26062015
	,@reportPath    varchar(max)=''
AS
	SET NOCOUNT ON 
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ARITHABORT ON 
	
	if @Branch_ID = 0
		set @Branch_ID = null
	if @Cat_ID = 0
		set @Cat_ID = null
	if @Type_ID = 0
		set @Type_ID = null
	if @Dept_ID = 0
		set @Dept_ID = null
	if @Grd_ID = 0
		set @Grd_ID = null
	if @Emp_ID = 0
		set @Emp_ID = null
	If @Desig_ID = 0
		set @Desig_ID = null
	If @PBranch_ID = 0 
		set @PBranch_ID = null
	
	--CREATE Table #Emp_Cons 
	--	(
	--		Emp_ID	numeric
	--	)
	
	--if @Constraint <> ''
	--	begin
	--		Insert Into #Emp_Cons
	--		select  cast(data  as numeric) from dbo.Split (@Constraint,'#') 
	--	end
	----else if @Letter ='Offer' --commented by Mukti(04012017)
	--ELSE
	--	begin
	--		Insert Into #Emp_Cons

	--		select	I.Emp_Id 
	--		from	T0095_Increment I 
	--				inner join T0080_Emp_Master e on i.Emp_ID = E.Emp_ID 
	--				inner join (
	--								select	max(Increment_ID) as Increment_ID , Emp_ID 
	--								from	T0095_Increment	-- Ankit 09092014 for Same Date Increment
	--								where	Increment_Effective_date <= @To_Date and Cmp_ID = @Cmp_ID
	--								group by emp_ID  
	--							) Qry on I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID
	--		Where	I.Cmp_ID = @Cmp_ID 
	--				and Isnull(I.Cat_ID,0) = Isnull(@Cat_ID ,Isnull(I.Cat_ID,0))
	--				and I.Branch_ID = isnull(@Branch_ID ,I.Branch_ID)
	--				and I.Grd_ID = isnull(@Grd_ID ,I.Grd_ID)
	--				and isnull(I.Dept_ID,0) = isnull(@Dept_ID ,isnull(I.Dept_ID,0))
	--				and Isnull(I.Type_ID,0) = isnull(@Type_ID ,Isnull(I.Type_ID,0))
	--				and Isnull(I.Desig_ID,0) = isnull(@Desig_ID ,Isnull(I.Desig_ID,0))
	--				and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID) 
	--				and Date_of_Join >=@From_Date and Date_OF_Join <=@to_Date
	--	end
		
		CREATE TABLE #EMP_CONS 
	 (      
		EMP_ID		 NUMERIC ,     
		BRANCH_ID	 NUMERIC,
		INCREMENT_ID NUMERIC
	 )      
	
		EXEC SP_RPT_FILL_EMP_CONS  @CMP_ID,@FROM_DATE,@TO_DATE,@BRANCH_ID,@CAT_ID,@GRD_ID,@TYPE_ID,@DEPT_ID,@DESIG_ID ,@EMP_ID ,@CONSTRAINT ,0 ,0 ,0,0,0,0,0,0,0,0,0,0	
		CREATE UNIQUE CLUSTERED INDEX IX_EMP_CONS_EMPID ON #EMP_CONS (EMP_ID);
		
		create table #Data_Table
			(    
				Ad_ID  Numeric,    
				Cmp_Id Numeric,    
				Emp_ID Numeric,    
				CTC    Numeric(18,2),    
				For_Date Datetime    
			 )
		
		Declare @EmpID numeric(18,0)

declare curCTC cursor
	for 
select Emp_ID from #Emp_Cons
open curCTC
	fetch next from curCTC into @EmpID
	while @@FETCH_STATUS = 0
	begin
			INSERT INTO #DATA_TABLE
			SELECT EED.Ad_ID,EED.cmp_id,EED.Emp_ID,EED.E_Ad_Amount,EED.For_Date
			FROM T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK)
				INNER JOIN T0050_AD_MASTER AM WITH (NOLOCK) ON EED.AD_ID = AM.AD_ID
				INNER JOIN #EMP_CONS EC ON EED.EMP_ID = EC.EMP_ID AND EED.INCREMENT_ID = EC.INCREMENT_ID
				INNER JOIN T0095_INCREMENT INC WITH (NOLOCK) ON INC.Increment_ID = EC.INCREMENT_ID
			WHERE AM.CMP_ID=@CMP_ID AND EED.EMP_ID = @EmpID
					AND AM.AD_PART_OF_CTC = 1 
					AND EED.E_AD_FLAG = 'I'
					AND EED.FOR_DATE >= @FROM_DATE
					AND EED.FOR_DATE <= @TO_DATE

		   --Insert into #Data_Table    
		   --select		AM.Ad_ID,EEM.cmp_id,EEM.Emp_ID,EEM.E_Ad_Amount,EEM.For_Date     
		   --from			t0050_ad_master am 
					--	Left outer join  t0100_emp_earn_deduction EEM on am.Ad_ID = EEM.Ad_ID 
					--	inner join t0095_increment I on eem.INCREMENT_ID = i.Increment_ID and I.Increment_Type = 'Joining' --Added By Ramiz on 23022018 , As CTC was coming Wrong in Appointment Letter
					--	--Inner join  t0080_emp_master EM on EEM.Emp_ID = EM.Emp_ID 
					--	--inner join  t0095_increment I on EM.Increment_ID = I.Increment_Id
		   --where		am.cmp_id=@Cmp_ID  And EEM.Emp_ID = @EmpID 
					--	And am.AD_PART_OF_CTC=1 
					--	--and i.Increment_Effective_Date = EEM.For_Date 
					--	and EEM.E_AD_Flag = 'I'
					--	and eem.FOR_DATE >= @From_Date
					--	and eem.FOR_DATE <= @To_Date

	fetch next from curCTC into @EmpID
	End
	close curCTC
deallocate curCTC

		--select * from #Data_Table
		--if @Letter ='Offer' --commented by Mukti(04012017)
			--begin
					select	I_Q.* 
							,E.Emp_Full_Name 
							,E.Emp_Code
							,BM.Comp_Name
							,BM.Branch_Address
							,DM.Dept_Name
							,DGM.Desig_Name
							,ETM.Type_Name
							,GM.Grd_Name
							,BM.Branch_Name
							,E.Date_of_Join
							,E.Gender
							,Cmp_Name
							,Cmp_Address
							,E.Present_Street
							,E.Present_State
							,E.Present_City
							,E.Present_Post_Box
							,BM.Branch_City
							,E.Street_1
							,E.City
							,E.Zip_code
							,CM.cmp_logo
							,ETM.Type_Name
							,case when E.Probation > 0 then E.Probation else GS.Probation end as Probation 
							,CM.Cmp_HR_Manager
							,Cmp_HR_Manager_Desig
							,BM.branch_code
							,I_Q.Gross_Salary,((IsNull(dt1.CTC,0)) + I_Q.Basic_Salary) AS ctc
							,EM1.Emp_Full_Name as 'Reporting Name'
							,Dgm1.Desig_Name as 'Reporting Designation'
							,EM1.Mobile_No as R_Mobile_no
							,dbo.F_Number_TO_Word(I_Q.Gross_Salary) as Amount_In_Word
							,CM.cmp_code
							,BM.branch_code
							,E.Street_1
							,E.City
							,E.State
							,E.Zip_code
							,E.Tehsil
							,E.District
							,E.alpha_emp_code
							,E.father_Name
							,GS.Short_Fall_Days
							,E.Emp_First_Name    --added jimit 25052015
							,Cm.Cmp_City		 --added jimit 04032016
							,ELR.Reference_No,ELR.Issue_Date
							,Cmp_HR_Manager AS HR  --changed by jimit 25022017
							,E.Emp_Notice_Period
							,(SELECT setting_Value from T0040_SETTING WITH (NOLOCK) where Cmp_ID = @Cmp_Id and Setting_Name = 'Employee Retirement Age')as Retirement_Age --added jimit 28032016
							,E.Mobile_No--,I_Q.Basic_Salary
							,SBR.SubBranch_Name  --added jimit 22072016
							,dbo.F_Number_TO_Word(((isnull(dt1.CTC,0)+ I_Q.Basic_Salary )* 12)) as CTC_Amnt_InWord_PerAnnum --Added by Sumit on 06/08/2016					
							,Qry_Director.Director_Name --added by chetan 10112017
							,HRR.Job_Description --added by Krushna 20-09-2018
							,BS.Segment_Name --added by Krushna 28-09-2018
							,GM.Short_Fall_W_Days	--added by krushna 21-11-2018
							,CCM.Center_Name		--added by Krusna 22-11-2018
							,CAST(@reportPath as varchar(max)) + '\report_image\header_' + cast (cm.cmp_id as varchar) + '.bmp' as rp_header
							,CAST(@reportPath as varchar(max)) + '\report_image\Footer_' + cast (cm.cmp_id as varchar) + '.bmp' as rp_Footer
							,replace(CAST(@reportPath as varchar(max)),'\Reports\','') + '\App_File\Signature\' + cast (Signature as varchar(max)) as rp_Sign
							,dbo.F_GET_AGE (E.Date_Of_Birth,GETDATE(),'N','N') as Emp_Age
							,E.Father_name As Emp_Father_Name
							,CGM.CAT_Name
							,E.Emp_Last_Name
							,E.Initial
							,E.Tehsil_Wok,
							Concat(SM.Shift_St_Time,' To ',sm.Shift_End_Time) as ShiftTime -- Added by ronakk 01042022
							,E.Emp_First_Name  -- Added by ronakk 17102022
							,E.Alpha_Emp_Code  -- Added by ronakk 17102022 
					from	T0080_EMP_MASTER E WITH (NOLOCK) 
							inner join #Emp_Cons ec on e.emp_ID =ec.emp_ID 
							inner join (
											select	I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID,Gross_Salary,I.Cmp_ID,I.Basic_Salary,I.subBranch_ID,I.Segment_ID,I.Center_ID,I.Wages_Type
											from	T0095_Increment I WITH (NOLOCK)
													inner join (
																	select	max(Increment_ID) as Increment_ID , Emp_ID 
																	from	T0095_Increment WITH (NOLOCK)	-- Ankit 09092014 for Same Date Increment
																	where	Increment_Effective_date <= @To_Date and Cmp_ID = @Cmp_ID
																	group by emp_ID  
																) Qry on I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID	 
										) I_Q on E.Emp_ID = I_Q.Emp_ID  
							inner join T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID 
							LEFT OUTER JOIN T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID 
							LEFT OUTER JOIN T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id 
							LEFT OUTER JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id 
							INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID  
							LEFT join (
											select	sum(CTC) as CTC,EMp_ID 
											from	#Data_Table 
											where	Cmp_Id=@Cmp_ID 
											group by Emp_ID
										) dt1 on E.Emp_ID = Dt1.Emp_ID 
							inner join T0010_COMPANY_MASTER CM WITH (NOLOCK) ON E.CMP_ID = CM.CMP_ID  --and dt1.CTC=dt.CTC inner join
							inner join T0040_GENERAL_SETTING GS WITH (NOLOCK) ON E.cmp_id = GS.Cmp_ID and I_Q.Branch_ID = Gs.Branch_ID 
							INNER JOIN (
											SELECT	MAX(GS.GEN_ID) AS GENID,GS.BRANCH_ID,GS.FOR_DATE 
											FROM	T0040_GENERAL_SETTING GS WITH (NOLOCK)
													INNER JOIN (
																	SELECT	MAX(FOR_DATE) AS FOR_DATE,BRANCH_ID 
																	FROM	T0040_GENERAL_SETTING WITH (NOLOCK)
																	WHERE	FOR_DATE<=@TO_DATE 
																	GROUP BY BRANCH_ID
																) GS1 ON GS.BRANCH_ID=GS1.BRANCH_ID AND GS.FOR_DATE = GS1.FOR_DATE
											WHERE	GS.FOR_DATE<=@TO_DATE GROUP BY GS.BRANCH_ID,GS.FOR_DATE
										)QRY ON GS.BRANCH_ID=QRY.BRANCH_ID AND GS.GEN_ID=QRY.GENID and GS.For_Date=Qry.For_Date 
								--left JOin T0090_EMP_REPORTING_DETAIL RD on E.Emp_id = RD.emp_id and E.cmp_id = RD.Cmp_id 
								--Left Join T0080_EMP_MASTER EM1 on  RD.R_Emp_Id = EM1.emp_id 
							LEFT JOIN (
											SELECT	Q.EMP_ID,MAX(RD.R_EMP_ID) AS R_EMP_ID 
											FROM	T0090_EMP_REPORTING_DETAIL RD WITH (NOLOCK)
													INNER JOIN (
																	SELECT	MAX(EFFECT_DATE) MAX_DATE,EMP_ID 
																	FROM	T0090_EMP_REPORTING_DETAIL WITH (NOLOCK)
																	WHERE	EFFECT_DATE <= getdate() AND CMP_ID = @CMP_ID 
																	GROUP BY EMP_ID
																)Q ON Q.EMP_ID = RD.EMP_ID AND Q.MAX_DATE = RD.EFFECT_DATE								 
											GROUP BY Q.EMP_ID
										)MAIN ON Main.Emp_ID = Ec.Emp_ID 
							LEFT JOIN T0080_EMP_MASTER EM1 WITH (NOLOCK) ON MAIN.R_EMP_ID = EM1.EMP_ID 
							left join T0040_DESIGNATION_MASTER DGM1 WITH (NOLOCK) on EM1.Desig_Id = DGM1.Desig_Id and EM1.Cmp_Id=DGM1.Cmp_Id 
							Left JOIN T0050_SubBranch SBR WITH (NOLOCK) On SBR.SubBranch_ID = I_Q.subBranch_ID and sbr.Cmp_ID = I_Q.Cmp_ID 								 --added jimit 22072016
							left join T0081_Emp_LetterRef_Details ELR WITH (NOLOCK) on ELR.Emp_Id = e.Emp_ID and ELR.Letter_Name=@Letter  --Mukti(04012017)
							--added by chetan 10112017
							LEFT JOIN (
											SELECT	TOP	1 Cmp_ID,Director_Name 
											FROM	T0010_COMPANY_DIRECTOR_DETAIL WITH (NOLOCK)
											WHERE	Cmp_Id=@Cmp_ID 
										) Qry_Director ON E.Cmp_ID = Qry_Director.Cmp_Id 
								--(SELECT		(SUM(ISNULL(EED.E_AD_AMOUNT,0))) AS E_Ad_Amount,EED.Emp_ID		--added by jimit 21092016
								-- FROM		T0100_EMP_EARN_DEDUCTION EED INNER JOIN								
								--			T0050_AD_MASTER AM ON Am.AD_ID = EEd.AD_ID 
								-- WHERE		am.CMP_ID = 1 AND ad_part_of_ctc = 1 AND AD_FLAG = 'I' AND ISNULL(Allowance_Type,'A') <> 'R'
								-- GROUP BY EED.EMP_ID)Q ON E.Emp_ID = Q.emp_Id							
							LEFT OUTER JOIN T0060_RESUME_FINAL RF WITH (NOLOCK) ON E.EMP_ID=RF.Confirm_Emp_ID
							LEFT OUTER JOIN T0052_HRMS_POSTED_RECRUITMENT POST WITH (NOLOCK) ON RF.Rec_Post_ID=POST.Rec_Post_ID
							LEFT OUTER JOIN T0050_HRMS_RECRUITMENT_REQUEST HRR WITH (NOLOCK) ON POST.Rec_Req_ID = HRR.Rec_Req_ID
							left outer join T0040_Business_Segment BS WITH (NOLOCK) on I_Q.Segment_ID = BS.Segment_ID
							LEFT OUTER JOIN T0040_COST_CENTER_MASTER CCM WITH (NOLOCK) ON I_Q.Center_ID = CCM.Center_ID
							LEFT OUTER JOIN T0030_CATEGORY_MASTER CGM WITH (NOLOCK) ON I_Q.Cat_ID = CGM.Cat_ID	--added by Krishna 02112019 
							left join T0100_EMP_SHIFT_DETAIL ESD WITH (NOLOCK) ON ESD.Emp_ID = E.Emp_ID  -- Added by ronakk 01042022
							left join T0040_SHIFT_MASTER SM WITH (NOLOCK) ON SM.Shift_ID = ESD.Shift_ID  -- Added by ronakk 01042022
					WHERE E.Cmp_ID = @Cmp_ID and E.Date_of_Join >=@From_Date and E.Date_OF_Join <=@to_Date
			--end	
		
	drop table #Data_Table	
		
	RETURN




