-- exec prc_BindFamilyDetails 193,0,25564,0,0,'23/08/2021'
-- drop proc prc_BindFamilyDetails
CREATE procedure [dbo].[prc_BindFamilyDetails]
@rClaimId INT,
@rAmount float = null,
@rEmpId BIGINT,
@rRowId INT = null,
@rClaimAppDetailId INT = null,
@rFromDate VARCHAR(50) = null
as
begin
	DECLARE @lFamilyResult varchar(max) = '',@lOptionRes varchar(max) = ''
	DECLARE @lLimitType INT,@lIsBeyondLimit INT,@lClaimType INT,@lClaimLimitType INT
	DECLARE @lBranchId INT,@lDesignationId INT,@lGradeId INT,@lIncrementId INT
	DECLARE @lBasicSalary float,@lGrossSalary float,@Limit float
	DECLARE @lMonth INT,@lYear INT,@lAge INT,@lMainType INT
	DECLARE @lDays INT,@lCurrentMontDays INT,@lProrateLimitFlag INT,@lMonths INT
	DECLARE @lReleaseMonth INT,@rCmpId INT,@lYearType INT,@lCount INT,@li INT
	DECLARE @lFirstDate VARCHAR(50),@lLastDate VARCHAR(50)
	DECLARE @lJoinDate datetime,@lNewDate datetime,@lReleaseFirstDate datetime,@lReleaseLastDate datetime
	DECLARE @lApplicationAmount float,@lApprovalAmount float,@lNewLimit float,@lRatePerKM float,@lflagRateOrUnit int = 0
	DECLARE @lApplicableOnceBasedOnLimit INT,@lNoOfYearLimit INT,@lResult INT = 1,@lUnitName varchar(100)
	DECLARE @lDate varchar(50) = '',@lApprovaldate datetime
	DECLARE @lConversionRate float,@lUnitId int,@lMinKm float
	DECLARE @lAfter_Joining_Days INT,@lAllowFlag INT = 1
	DECLARE @lLimitFlag INT -- Grade_Wise_Limit then 1
							-- Branch_Wise_Limit then 2
							-- Desig_Wise_Limit then 3
							-- Gross_Salary_wise then 4
							-- Basic_Salary_wise then 5
							-- Fix then 6
							-- Agewise then 7
							-- GradeAgeWise then 8
							
	SELECT @rFromDate = CASE ISNULL(@rFromDate,'') WHEN '' THEN '' ELSE CONVERT(VARCHAR(10), CONVERT(DATE, @rFromDate, 105), 23) END
	SELECT @lMonth = MONTH(@rFromDate),@lYear = YEAR(@rFromDate)
	SELECT @lFirstDate = DATEADD(month,@lMonth-1,DATEADD(year,@lYear-1900,0))
	SELECT @lLastDate = DATEADD(day,-1,DATEADD(month,@lMonth,DATEADD(year,@lYear-1900,0)))
	
	SELECT @lIsBeyondLimit = isnull(CLAIM_ALLOW_BEYOND_LIMIT,0),@lClaimType = isnull(Claim_Type,0),@lClaimLimitType = isnull(Claim_Limit_Type,0),@lMainType = ISNULL(Claim_Main_Type,0),
	@lReleaseMonth = ISNULL(Claim_ForMonth,0),@lYearType = isnull(YearBy,0),@lApplicableOnceBasedOnLimit = isnull(Claim_ApplicableOnceBasedOnLimit,0),@lNoOfYearLimit = isnull(No_Of_Year_Limit,0),
	@lLimitFlag = CASE WHEN isnull(Grade_Wise_Limit,0) = 1 then 1 WHEN isnull(Branch_Wise_Limit,0) = 1 then 2 when isnull(Desig_Wise_Limit,0) = 1 then 3
	when isnull(Gross_Salary_wise,0) = 1 then 4 when isnull(Basic_Salary_wise,0) = 1 then 5 when isnull(Claim_Max_Limit,0) > 0 then 6 when isnull(Age_Wise_Limit,0) = 1 then 7 when ISNULL(Grade_Age_Limit,0) = 1 then 8 END,
	@Limit = isnull(Claim_Max_Limit,0),@rCmpId = CM.Cmp_ID,@lAfter_Joining_Days = isnull(After_Joining_Days,0),@lUnitId = isnull(Unit_Id,0),@lUnitName = isnull(Unit_Type_Name,'')
	from T0040_CLAIM_MASTER CM
	left join T0040_Unit_Type_Master on Unit_Id = Unit_Type_Id
	where Claim_ID = @rClaimId
	
	select top 1 @lConversionRate = FUEL_RATE from T0180_FUEL_CONVERSION where Fuel_type = @lUnitId order by FOR_DATE desc

	select @lFamilyResult = @lFamilyResult + '<tr><td style="text-align:center;"><input type="checkbox" id="chkSelect" /></td>
	<td>' + ISNULL(Name,'') + '</td><td>' + ISNULL(Relationship,'') + '</td><td>' + CONVERT(varchar,isnull(C_Age,0)) + '</td>
	<td>' + convert(varchar,isnull((select isnull(Age_Amount,0) from T0041_Claim_Maxlimit_Age where Claim_Id = @rClaimId and C_Age between Age_Min and Age_Max and isnull(GradeId,0) = case when @lLimitFlag = 8 then @lGradeId else 0 end),0)) + '</td>
	<td><input type="text" class="input txtAmount" onkeypress="return isDecimalKey(event, this);" onblur="getValues(this);" /></td></tr>'
	from T0090_EMP_CHILDRAN_DETAIL
	where Emp_ID = @rEmpId 

	SELECT @lBranchId = Q_I.Branch_ID,@lDesignationId = Q_I.Desig_Id,@lGradeId = Q_I.Grd_ID,@lBasicSalary = Q_I.Basic_Salary,@lGrossSalary = Q_I.Gross_Salary,
	@lAge = DATEDIFF(YEAR,Date_Of_Birth,GETDATE()),@lIncrementId = IncrementId,@lJoinDate = ISNULL(GroupJoiningDate,Date_Of_Join)
	from T0080_EMP_MASTER EM
	INNER JOIN
	(
		SELECT I.branch_id, I.grd_id, I.dept_id, I.desig_id, I.emp_id ,i.Cmp_ID,i.Basic_Salary,i.Gross_Salary,i.Increment_ID as IncrementId
		FROM t0095_increment I 
		INNER JOIN
		(
			SELECT Max(increment_effective_date) AS For_Date, emp_id 
			FROM t0095_increment 
			WHERE increment_effective_date <= Getdate() AND Emp_ID = @rEmpId
			AND Increment_Type not in ('Transfer','Deputation')
			GROUP  BY emp_id
		) Qry ON I.emp_id = Qry.emp_id AND I.increment_effective_date = Qry.for_date
	) Q_I ON EM.Emp_ID = Q_I.emp_id
	where EM.Emp_ID = @rEmpId

	if @lLimitFlag = 1
	begin
		select @Limit = case when isnull(Max_Limit_Km,0) = 0 then Max_Unit * isnull(@lConversionRate,1) else isnull(Max_Limit_Km,Max_Unit * @lConversionRate) end,
		@lRatePerKM = case when isnull(Rate_Per_Km,0) = 0 then Max_Unit else isnull(Rate_Per_Km,Max_Unit) end,
		@lflagRateOrUnit = case when isnull(Rate_Per_Km,0) = 0 then 1 else 0 end,
		@lAfter_Joining_Days = case when ISNULL(@lAfter_Joining_Days,0) = 0 then isnull(After_Joining_Days,0) else @lAfter_Joining_Days end,
		@lMinKm = Min_KM
		from T0041_Claim_Maxlimit_Design where Claim_ID = @rClaimId and Grade_ID = @lGradeId
	end
	else if @lLimitFlag = 2
	begin
		select @Limit = case when isnull(Max_Limit_Km,0) = 0 then Max_Unit * isnull(@lConversionRate,1) else isnull(Max_Limit_Km,Max_Unit * @lConversionRate) end,
		@lRatePerKM = case when isnull(Rate_Per_Km,0) = 0 then Max_Unit else isnull(Rate_Per_Km,Max_Unit) end,
		@lflagRateOrUnit = case when isnull(Rate_Per_Km,0) = 0 then 1 else 0 end,
		@lAfter_Joining_Days = case when ISNULL(@lAfter_Joining_Days,0) = 0 then isnull(After_Joining_Days,0) else @lAfter_Joining_Days end,
		@lMinKm = Min_KM
		from T0041_Claim_Maxlimit_Design where Claim_ID = @rClaimId and Branch_ID = @lBranchId
	end
	else if @lLimitFlag = 3
	begin
		select @Limit = case when isnull(Max_Limit_Km,0) = 0 then Max_Unit * isnull(@lConversionRate,1) else isnull(Max_Limit_Km,Max_Unit * @lConversionRate) end,
		@lRatePerKM = case when isnull(Rate_Per_Km,0) = 0 then Max_Unit else isnull(Rate_Per_Km,Max_Unit) end,
		@lflagRateOrUnit = case when isnull(Rate_Per_Km,0) = 0 then 1 else 0 end,
		@lAfter_Joining_Days = case when ISNULL(@lAfter_Joining_Days,0) = 0 then isnull(After_Joining_Days,0) else @lAfter_Joining_Days end,
		@lMinKm = Min_KM
		from T0041_Claim_Maxlimit_Design where Claim_ID = @rClaimId and Desig_ID = @lDesignationId
	end
	else if @lLimitFlag = 4
	begin
		select @Limit = @lGrossSalary + isnull((SELECT SUM(E_AD_AMOUNT) as TotalAmount FROM DBO.fn_getEmpIncrementDetail(@rClaimId,@rEmpId,getdate()) EI
		INNER JOIN T0050_AD_MASTER AD ON EI.AD_ID=AD.AD_ID WHERE EI.E_AD_FLAG='I' AND AD_NOT_EFFECT_SALARY=0),0)
		select @lRatePerKM = 0,@lMinKm = 0
	end
	else if @lLimitFlag = 5
	begin
		select @Limit = @lBasicSalary,@lRatePerKM = 0,@lMinKm = 0
	end
	else if @lLimitFlag = 6
	begin
		select @Limit = Claim_Max_Limit,@lRatePerKM = 0,@lMinKm = 0 from T0040_CLAIM_MASTER where Claim_ID = @rClaimId
	end
	else if @lLimitFlag = 7
	begin
		select @Limit = Age_Amount,@lRatePerKM = 0,@lMinKm = 0 from T0041_Claim_Maxlimit_Age where Claim_Id = @rClaimId and @lAge between Age_Min and Age_Max
	end
	else if @lLimitFlag = 8
	begin
		select @Limit = Age_Amount,@lRatePerKM = 0,@lMinKm = 0 from T0041_Claim_Maxlimit_Age where Claim_Id = @rClaimId and @lAge between Age_Min and Age_Max and GradeId = @lGradeId
	end
	
	if isnull(@rRowId,0) > 0
	begin
		select @Limit = (isnull((select isnull(Age_Amount,0) from T0041_Claim_Maxlimit_Age where Claim_Id = @rClaimId and C_Age between Age_Min and Age_Max),0)),@lRatePerKM = 0,@lMinKm = 0
		from T0090_EMP_CHILDRAN_DETAIL where Emp_ID = @rEmpId and (Row_ID = @rRowId or isnull(@rRowId,0) = 0) order by Row_ID
	end
	
	if isnull(@rClaimAppDetailId,0) > 0
	begin
		if exists(select 1 from T0110_CLAIM_APPLICATION_DETAIL where Claim_App_Detail_ID = @rClaimAppDetailId and Claim_Limit > 0)
		begin
			select @Limit = isnull(Claim_Limit,0) from T0110_CLAIM_APPLICATION_DETAIL where Claim_App_Detail_ID = @rClaimAppDetailId
		end
	end

	select @lMonth = case when @lYearType = 1 then 1 else 4 end,@lYear = YEAR(@rFromDate)
	
	select @lProrateLimitFlag = CASE @lClaimLimitType WHEN 1 then 1 WHEN 2 THEN 12 WHEN 3 THEN 3 WHEN 4 then 4 WHEN 5 then 2 END,
	@lCount = CASE @lClaimLimitType WHEN 1 then 1 WHEN 2 THEN 1 WHEN 3 THEN 4 WHEN 4 then 3 WHEN 5 then 2 END
	
	select @li = 1
	
	if @lYearType = 1
	begin
		select @lReleaseFirstDate = DATEADD(month,@lMonth-1,DATEADD(year,@lYear-1900,0))
	end
	else
	begin
		if @rFromDate < DATEADD(d, -1, DATEADD(m, DATEDIFF(m, 0, @rFromDate) + 1, 0))
		begin
			select @lReleaseFirstDate = DATEADD(month,@lMonth-1,DATEADD(year,(@lYear-1)-1900,0))
		end
		else
		begin
			select @lReleaseFirstDate = DATEADD(month,@lMonth-1,DATEADD(year,@lYear-1900,0))
		end
	end
	
	declare @tblDates table(tid int identity(1,1),t_StartDate smalldatetime,t_EndDate smalldatetime)
	
	while @li <= @lCount
	begin
		if @lDate = ''
		begin
			select @lReleaseLastDate = DATEADD(mm,@lProrateLimitFlag,@lReleaseFirstDate)
		end
		else
		begin
			select @lReleaseFirstDate = @lReleaseLastDate
			select @lReleaseLastDate = DATEADD(mm,@lProrateLimitFlag,@lReleaseLastDate)
		end
		insert into @tblDates
		(
			t_StartDate,t_EndDate
		)
		select @lReleaseFirstDate,DATEADD(day,-1,@lReleaseLastDate)
		select @lDate = convert(varchar,@lReleaseFirstDate,103)
		select @li = @li + 1
	end
	
	select @lFirstDate = t_StartDate,@lLastDate = t_EndDate from @tblDates where @rFromDate between t_StartDate and t_EndDate
	
	if @lMainType = 1
	begin
		if @lClaimLimitType <> 0
		begin
			if @lJoinDate between @lFirstDate and @lLastDate
			begin
				select @lDays = DATEDIFF(day,@lJoinDate,@lLastDate)
				select @lDays = @lDays + 1

				select @lCurrentMontDays = datediff(day,@lFirstDate,@lLastDate)
				select @lCurrentMontDays = @lCurrentMontDays + 1
				
				select @Limit = ((@Limit / @lCurrentMontDays) * @lDays)
			end			
		end		
	end	

	if isnull(@lAfter_Joining_Days,0) > 0
	begin
		if DATEDIFF(day,@lJoinDate,@rFromDate) < @lAfter_Joining_Days
		begin
			select @lAllowFlag = 0
		end
		else
		begin
			select @lAllowFlag = 1
		end
	end
	else
	begin
		select @lAllowFlag = 1
	end

	select @lApplicationAmount = SUM(isnull(Application_Amount,0))
	from T0110_CLAIM_APPLICATION_DETAIL CAD
	inner join T0100_CLAIM_APPLICATION ca on ca.claim_app_id=cad.claim_app_id
	inner join T0040_CLAIM_MASTER cm on cm.Claim_ID=cad.Claim_ID and cm.Cmp_ID=cad.Cmp_ID	
	where cad.Cmp_ID= @rCmpId and for_date between @lFirstDate and @lLastDate and cm.Claim_ID=@rClaimId and ca.emp_id=@rEmpId and ca.Claim_App_Status='P'
	and isnull(Claim_FamilyMeberId,0) = case when isnull(@rRowId,0) = 0 then 0 else @rRowId end
		
	select @lApprovalAmount = sum(isnull(cad.Claim_Apr_Amount,cad.Claim_App_Amount))
	from T0130_CLAIM_APPROVAL_DETAIL cad
	inner join T0120_CLAIM_APPROVAL ca on ca.Claim_Apr_ID=cad.Claim_Apr_ID
	inner join T0040_Claim_master cm on cm.Claim_ID=cad.Claim_ID and cm.Cmp_ID=cad.Cmp_ID	
	where cad.Cmp_ID=@rCmpId and cad.Claim_Apr_Date between @lFirstDate and @lLastDate and cm.Claim_ID=@rClaimId and ca.emp_id=@rEmpId and cad.Claim_Status='A'
	and isnull(Claim_FamilyMeberId,0) = case when isnull(@rRowId,0) = 0 then 0 else @rRowId end

	select @lNewLimit = @Limit - (isnull(@lApplicationAmount,0) + isnull(@lApprovalAmount,0))

	if @lApplicableOnceBasedOnLimit = 1 and @lClaimLimitType in (1,3,4,5) and (@lApprovalAmount > 0 or @lApplicationAmount > 0)
	begin
		select @lNewLimit = 0,@lResult = 0
	end
	else if @lApplicableOnceBasedOnLimit = 0 and @lClaimLimitType = 2 and @lNoOfYearLimit > 0
	begin		
		select top 1 @lApprovaldate = ca.Claim_Apr_Date
		from T0130_CLAIM_APPROVAL_DETAIL cad
		inner join T0120_CLAIM_APPROVAL ca on ca.Claim_Apr_ID=cad.Claim_Apr_ID
		inner join T0040_Claim_master cm on cm.Claim_ID=cad.Claim_ID and cm.Cmp_ID=cad.Cmp_ID		
		where cad.Cmp_ID=@rCmpId and cm.Claim_ID=@rClaimId and ca.emp_id=@rEmpId and cad.Claim_Status='A'		
		order by ca.Claim_Apr_Date
		
		if @lApprovaldate is null or isnull(@lApprovaldate,'') = ''
		begin
			select top 1 @lFirstDate = ca.Claim_App_Date
			from T0110_CLAIM_APPLICATION_DETAIL CAD
			inner join T0100_CLAIM_APPLICATION ca on ca.claim_app_id=cad.claim_app_id
			inner join T0040_CLAIM_MASTER cm on cm.Claim_ID=cad.Claim_ID and cm.Cmp_ID=cad.Cmp_ID			
			where cad.Cmp_ID= @rCmpId and for_date between @lFirstDate and @lLastDate and cm.Claim_ID=@rClaimId and ca.emp_id=@rEmpId and ca.Claim_App_Status='P'			
		end

		if DATEDIFF(dd,@lApprovaldate,@rFromDate) <= (@lNoOfYearLimit * 365)
		begin
			select @lNewLimit = 0,@lResult = 0
		end		
	end
	
	select @lFamilyResult = @lFamilyResult + '<tr><td style="text-align:center;"><a href="javascript:;" onclick="SelectEmp(' + convert(varchar,@rEmpId) + ',' + convert(varchar,Row_ID) + ',this)">Select</a></td>
	<td>' + ISNULL(Name,'') + '</td><td>' + ISNULL(Relationship,'') + '</td><td>' + CONVERT(varchar,isnull(C_Age,0)) + '</td>
	<td class="tdlimit">' + convert(varchar,isnull((select isnull(Age_Amount,0) from T0041_Claim_Maxlimit_Age
	where Claim_Id = @rClaimId and C_Age between Age_Min and Age_Max and isnull(GradeId,0) = case when @lLimitFlag = 8 then @lGradeId else 0 end),@Limit) - CASE WHEN FDD.Amount IS NULL THEN 0 ELSE isnull(FDD.Amount,0) END) + '</td></tr>',
	@lOptionRes = @lOptionRes + '<option value="' + convert(varchar,Row_ID) + '">' + ISNULL(Name,'') + '</option>'
	from T0090_EMP_CHILDRAN_DETAIL
	left join
	(
		select MemberId,sum(Amount) as Amount from
		(
			select FD.Claim_FamilyMemberId as MemberId,sum(isnull(FD.Claim_Amount,0)) as Amount
			from T0100_CLAIM_APPLICATION CA
			inner join T0110_CLAIM_APPLICATION_DETAIL CAD on CA.Claim_App_ID = CAD.Claim_App_ID
			left join T0110_Claim_FamilyDetails FD on CA.Claim_App_ID = Claim_AppId
			where ClaimId = @rClaimId and CA.Claim_ID = @rClaimId
			and for_date between @lFirstDate and @lLastDate
			and CA.Claim_App_Status='P'
			group by FD.Claim_FamilyMemberId

			union all

			select FD.Claim_FamilyMemberId as MemberId,sum(isnull(FD.Claim_Amount,0)) as Amount
			from T0120_CLAIM_APPROVAL CA
			inner join T0130_CLAIM_APPROVAL_DETAIL CAD on CA.Claim_App_ID = CAD.Claim_App_ID
			left join T0110_Claim_Approval_FamilyDetails FD on CA.Claim_App_ID = Claim_AppId
			where ClaimId = @rClaimId and CA.Claim_ID = @rClaimId
			and CAD.Claim_Apr_Date between @lFirstDate and @lLastDate
			and CAD.Claim_Status='A'
			group by FD.Claim_FamilyMemberId
		) t group by MemberId
	) FDD on FDD.MemberId = Row_ID
	where Emp_ID = @rEmpId order by case when Name = 'Self' then ' ' else Name end

	select top 1 isnull(@lFamilyResult,'') as FamilyDetails,isnull(@lOptionRes,'') as OptionRes,Row_ID as RowId,ISNULL(Name,'') as Title,ISNULL(Relationship,'') as Relation,isnull(C_Age,0) as Age,
	isnull((select isnull(Age_Amount,0) from T0041_Claim_Maxlimit_Age where Claim_Id = @rClaimId and C_Age between Age_Min and Age_Max
	and isnull(GradeId,0) = case when @lLimitFlag = 8 then @lGradeId else 0 end),@Limit) - CASE WHEN FDD.Amount IS NULL THEN 0 ELSE isnull(FDD.Amount,0) END as Limit,'' as Amount,
	isnull(convert(varchar,Date_Of_Birth,103),'') as BirthDate,'' as BillNo,'' as BillDate,'' as BillAmount
	from T0090_EMP_CHILDRAN_DETAIL
	left join
	(
		select MemberId,sum(Amount) as Amount from
		(
			select FD.Claim_FamilyMemberId as MemberId,sum(isnull(FD.Claim_Amount,0)) as Amount
			from T0100_CLAIM_APPLICATION CA
			inner join T0110_CLAIM_APPLICATION_DETAIL CAD on CA.Claim_App_ID = CAD.Claim_App_ID
			left join T0110_Claim_FamilyDetails FD on CA.Claim_App_ID = Claim_AppId
			where ClaimId = @rClaimId and CA.Claim_ID = @rClaimId
			and for_date between @lFirstDate and @lLastDate
			and CA.Claim_App_Status='P'
			group by FD.Claim_FamilyMemberId
			
			union all

			select FD.Claim_FamilyMemberId as MemberId,sum(isnull(FD.Claim_Amount,0)) as Amount
			from T0120_CLAIM_APPROVAL CA
			inner join T0130_CLAIM_APPROVAL_DETAIL CAD on CA.Claim_App_ID = CAD.Claim_App_ID
			left join T0110_Claim_Approval_FamilyDetails FD on CA.Claim_App_ID = Claim_AppId
			where ClaimId = @rClaimId and CA.Claim_ID = @rClaimId
			and CAD.Claim_Apr_Date between @lFirstDate and @lLastDate
			and CAD.Claim_Status='A'
			group by FD.Claim_FamilyMemberId
		) t group by MemberId
	) FDD on FDD.MemberId = Row_ID
	where Emp_ID = @rEmpId order by case when Name = 'Self' then ' ' else Name end


	IF OBJECT_ID(N'tempdb..#tmpRelation') IS NOT NULL	BEGIN		DROP TABLE #tmpRelation	END	Create table #tmpRelation (
		RelationId varchar(100)
	)

	declare @Rel_type as varchar(50)
	,@relid as varchar(max) 
	
	
	SELECT @relid = Relation_Id FROM T0040_CLAIM_MASTER WHERE Cmp_ID = @rCmpId and Claim_ID = @rClaimId

	if @relid <> ''
	Begin
		Insert into #tmpRelation
		SELECT Relationship
		FROM T0040_Relationship_Master rm where Relationship_ID in (Select Cast(Data As Numeric) as RelationId FROM dbo.Split(@relid,'#'))
		and Cmp_Id = @rCmpId 
	End

	
	
	select Row_ID as Id,ISNULL(Name,'') as Title,ISNULL(Relationship,'') as Relation,isnull(C_Age,0) as Age,
	isnull((select isnull(Age_Amount,0) from T0041_Claim_Maxlimit_Age where Claim_Id = @rClaimId and C_Age between Age_Min and Age_Max
	and isnull(GradeId,0) = case when @lLimitFlag = 8 then @lGradeId else 0 end),@Limit) - CASE WHEN FDD.Amount IS NULL THEN 0 ELSE isnull(FDD.Amount,0) END as Limit,'' as Amount,
	isnull(convert(varchar,Date_Of_Birth,103),'') as BirthDate,'' as BillNo,'' as BillDate,'' as BillAmount
	from T0090_EMP_CHILDRAN_DETAIL cd inner join #tmpRelation tr on tr.RelationId = cd.Relationship
	left join
	(
		select MemberId,sum(Amount) as Amount from
		(
			select FD.Claim_FamilyMemberId as MemberId,sum(isnull(FD.Claim_Amount,0)) as Amount
			from T0100_CLAIM_APPLICATION CA
			inner join T0110_CLAIM_APPLICATION_DETAIL CAD on CA.Claim_App_ID = CAD.Claim_App_ID
			left join T0110_Claim_FamilyDetails FD on CA.Claim_App_ID = Claim_AppId
			where ClaimId = @rClaimId and CA.Claim_ID = @rClaimId
			and for_date between @lFirstDate and @lLastDate
			and CA.Claim_App_Status='P'
			group by FD.Claim_FamilyMemberId

			union all

			select FD.Claim_FamilyMemberId as MemberId,sum(isnull(FD.Claim_Amount,0)) as Amount
			from T0120_CLAIM_APPROVAL CA
			inner join T0130_CLAIM_APPROVAL_DETAIL CAD on CA.Claim_App_ID = CAD.Claim_App_ID
			left join T0110_Claim_Approval_FamilyDetails FD on CA.Claim_App_ID = Claim_AppId
			where ClaimId = @rClaimId and CA.Claim_ID = @rClaimId
			and CAD.Claim_Apr_Date between @lFirstDate and @lLastDate
			and CAD.Claim_Status='A'
			group by FD.Claim_FamilyMemberId
		) t group by MemberId
	) FDD on FDD.MemberId = Row_ID
	where Emp_ID = @rEmpId and 
	Relationship = tr.RelationId
	--Is_Dependant = 1 
	order by case when Name = 'Self' then ' ' else Name end

	select Row_ID as Id,ISNULL(Name,'') as Title,ISNULL(Relationship,'') as Relation,isnull(C_Age,0) as Age,@lAfter_Joining_Days as AfterJoiningDays,@lAllowFlag as AllowFlag,
	isnull((select isnull(Age_Amount,0) from T0041_Claim_Maxlimit_Age where Claim_Id = @rClaimId and C_Age between Age_Min and Age_Max and isnull(GradeId,0) = case when @lLimitFlag = 8 then @lGradeId else 0 end),@Limit) as Limit,'' as Amount,
	isnull(convert(varchar,Date_Of_Birth,103),'') as BirthDate,'' as BillNo,'' as BillDate,'' as BillAmount
	from T0090_EMP_CHILDRAN_DETAIL cd	inner join #tmpRelation tr on tr.RelationId = cd.Relationship
	where Emp_ID = @rEmpId and (Row_ID = @rRowId or isnull(@rRowId,0) = 0) and 
	Relationship = tr.RelationId
	--Is_Dependant = 1 
	order by case when Name = 'Self' then ' ' else Name end
end