-- exec prc_CheckClaimLimit 214,0,25564,0,0,'02/09/2021'
-- drop procedure prc_CheckClaimLimit
CREATE PROCEDURE [dbo].[prc_CheckClaimLimit]
@rClaimId INT,
@rAmount float,
@rEmpId BIGINT,
@rRowId INT = null,
@rClaimAppDetailId INT = null,
@rClaimAprDetailId INT = null,
@rClaimAppId INT = null,
@rFromDate VARCHAR(50)
AS
BEGIN
	DECLARE @lLimitType INT,@lIsBeyondLimit INT,@lClaimType INT,@lClaimLimitType INT
	DECLARE @lBranchId INT,@lDesignationId INT,@lGradeId INT,@DesigId INT,@lIncrementId INT
	DECLARE @lBasicSalary float,@lGrossSalary float,@Limit float
	DECLARE @lMonth INT,@lYear INT,@lAge INT,@lMainType INT
	DECLARE @lDays INT,@lCurrentMontDays INT,@lProrateLimitFlag INT,@lMonths INT
	DECLARE @lReleaseMonth INT,@rCmpId INT,@lYearType INT,@lCount INT,@li INT
	DECLARE @lFirstDate VARCHAR(50),@lLastDate VARCHAR(50)
	DECLARE @lJoinDate datetime,@lNewDate datetime,@lReleaseFirstDate datetime,@lReleaseLastDate datetime
	DECLARE @lApplicationAmount float,@lApprovalAmount float,@lNewLimit float,@lRatePerKM float,@lflagRateOrUnit int = 0
	DECLARE @lApplicableOnceBasedOnLimit INT,@lNoOfYearLimit INT,@lResult INT = 1
	DECLARE @lDate varchar(50) = '',@lApprovaldate datetime
	DECLARE @lAfter_Joining_Days INT,@lAllowFlag INT = 1
	DECLARE @lConversionRate float,@lUnitId int,@lMinKm float
	DECLARE @lFamilyResult varchar(max) = '',@lUnitName varchar(100)
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
	@lLimitFlag = CASE WHEN isnull(Grade_Wise_Limit,0) = 1 then 1 
						WHEN isnull(Branch_Wise_Limit,0) = 1 then 2 
						when isnull(Desig_Wise_Limit,0) = 1 then 3
						when isnull(Gross_Salary_wise,0) = 1 then 4 
						when isnull(Basic_Salary_wise,0) = 1 then 5 
						when isnull(Claim_Max_Limit,0) > 0 then 6 
						when isnull(Age_Wise_Limit,0) = 1 then 7 
						when ISNULL(Grade_Age_Limit,0) = 1 then 8
						when ISNULL(Grade_City_Wise_Limit,0) = 1 then 9
						when ISNULL(Desig_City_Wise_Limit,0) = 1 then 9
						when ISNULL(HQ_City_Wise_Limit,0) = 1 then 9
						END,
	@Limit = isnull(Claim_Max_Limit,0),@rCmpId = CM.Cmp_ID,@lAfter_Joining_Days = isnull(After_Joining_Days,0),@lUnitId = isnull(Unit_Id,0),@lUnitName = isnull(Unit_Type_Name,'')
	from T0040_CLAIM_MASTER CM
	left join T0040_Unit_Type_Master on Unit_Id = Unit_Type_Id
	where Claim_ID = @rClaimId

	select top 1 @lConversionRate = FUEL_RATE from T0180_FUEL_CONVERSION where Fuel_type = @lUnitId and CMP_ID = @rCmpId and FOR_DATE <= @rFromDate order by FOR_DATE desc

	select @lFamilyResult = @lFamilyResult + '<tr><td style="text-align:center;"><input type="checkbox" id="chkSelect" /></td>
	<td>' + ISNULL(Name,'') + '</td><td>' + ISNULL(Relationship,'') + '</td><td>' + CONVERT(varchar,isnull(C_Age,0)) + '</td>
	<td>' + convert(varchar,isnull((select isnull(Age_Amount,0) from T0041_Claim_Maxlimit_Age where Claim_Id = @rClaimId and C_Age between Age_Min and Age_Max and isnull(GradeId,0) = case when @lLimitFlag = 8 then @lGradeId else 0 end),0)) + '</td>
	<td><input type="text" class="input txtAmount" onkeypress="return isDecimalKey(event, this);" onblur="getValues(this);" /></td></tr>'
	from T0090_EMP_CHILDRAN_DETAIL
	where Emp_ID = @rEmpId
		
	SELECT @lBranchId = Q_I.Branch_ID,@lDesignationId = Q_I.Desig_Id,@lGradeId = Q_I.Grd_ID,@DesigID = Q_I.Desig_Id,@lBasicSalary = Q_I.Basic_Salary,@lGrossSalary = Q_I.Gross_Salary,
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
		@lflagRateOrUnit = case when isnull(Rate_Per_Km,0) = 0 and @lUnitId > 0 then 1 else 0 end,
		@lAfter_Joining_Days = case when ISNULL(@lAfter_Joining_Days,0) = 0 then isnull(After_Joining_Days,0) else @lAfter_Joining_Days end,
		@lMinKm = Min_KM
		from T0041_Claim_Maxlimit_Design where Claim_ID = @rClaimId and Grade_ID = @lGradeId
	end
	else if @lLimitFlag = 2
	begin
		select @Limit = case when isnull(Max_Limit_Km,0) = 0 then Max_Unit * isnull(@lConversionRate,1) else isnull(Max_Limit_Km,Max_Unit * @lConversionRate) end,
		@lRatePerKM = case when isnull(Rate_Per_Km,0) = 0 then Max_Unit else isnull(Rate_Per_Km,Max_Unit) end,
		@lflagRateOrUnit = case when isnull(Rate_Per_Km,0) = 0 and @lUnitId > 0 then 1 else 0 end,
		@lAfter_Joining_Days = case when ISNULL(@lAfter_Joining_Days,0) = 0 then isnull(After_Joining_Days,0) else @lAfter_Joining_Days end,
		@lMinKm = Min_KM
		from T0041_Claim_Maxlimit_Design where Claim_ID = @rClaimId and Branch_ID = @lBranchId
	end
	else if @lLimitFlag = 3
	begin
		select @Limit = case when isnull(Max_Limit_Km,0) = 0 then Max_Unit * isnull(@lConversionRate,1) else isnull(Max_Limit_Km,Max_Unit * @lConversionRate) end,
		@lRatePerKM = case when isnull(Rate_Per_Km,0) = 0 then Max_Unit else isnull(Rate_Per_Km,Max_Unit) end,
		@lflagRateOrUnit = case when isnull(Rate_Per_Km,0) = 0 and @lUnitId > 0 then 1 else 0 end,
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
		select @Limit = @lBasicSalary,@lRatePerKM = 0,@lflagRateOrUnit = 2,@lMinKm = 0
	end
	else if @lLimitFlag = 6
	begin
		select @Limit = Claim_Max_Limit,@lRatePerKM = 0,@lflagRateOrUnit = 2,@lMinKm = 0 from T0040_CLAIM_MASTER where Claim_ID = @rClaimId
	end
	else if @lLimitFlag = 7
	begin
		select @Limit = Age_Amount,@lRatePerKM = 0,@lflagRateOrUnit = 2,@lMinKm = 0 from T0041_Claim_Maxlimit_Age where Claim_Id = @rClaimId and @lAge between Age_Min and Age_Max
	end
	else if @lLimitFlag = 8
	begin
		select @Limit = Age_Amount,@lRatePerKM = 0,@lflagRateOrUnit = 2,@lMinKm = 0 from T0041_Claim_Maxlimit_Age where Claim_Id = @rClaimId and @lAge between Age_Min and Age_Max and GradeId = @lGradeId
	end
	else if @lLimitFlag = 9
	begin
		select @Limit = City_cat_limit,@lRatePerKM = 0,@lflagRateOrUnit = 2,@lMinKm = 0 from T0041_Claim_Maxlimit_GradeDesig_CityWise where Claim_Id = @rClaimId  and (Grd_ID = @lGradeId or Desig_ID= @DesigId) 
	end
	if isnull(@rRowId,0) > 0
	begin
		select @Limit = (isnull((select isnull(Age_Amount,0) from T0041_Claim_Maxlimit_Age where Claim_Id = @rClaimId and C_Age between Age_Min and Age_Max and isnull(GradeId,0) = case when @lLimitFlag = 8 then @lGradeId else 0 end),0)),
		@lRatePerKM = 0,@lMinKm = 0
		from T0090_EMP_CHILDRAN_DETAIL where Emp_ID = @rEmpId and (Row_ID = @rRowId or isnull(@rRowId,0) = 0) order by Row_ID
	end
	
	if isnull(@rClaimAppDetailId,0) > 0
	begin
		if exists(select 1 from T0110_CLAIM_APPLICATION_DETAIL where Claim_App_Detail_ID = @rClaimAppDetailId and Claim_Limit > 0)
		begin
			select @Limit = isnull(Claim_Limit,0) from T0110_CLAIM_APPLICATION_DETAIL where Claim_App_Detail_ID = @rClaimAppDetailId
		end
	end

		if isnull(@rClaimAprDetailId,0) > 0
	begin
		if exists(select 1 from T0115_CLAIM_LEVEL_APPROVAL_DETAIL where Claim_Apr_ID = @rClaimAprDetailId and Claim_Limit > 0)
		begin
			select @Limit = isnull(Claim_Limit,0) from T0115_CLAIM_LEVEL_APPROVAL_DETAIL where Claim_Apr_ID = @rClaimAprDetailId
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

	if @lClaimLimitType = 0 
	Begin
		declare @flag numeric
		
		select @flag = 1 from T0110_CLAIM_APPLICATION_DETAIL where Cmp_ID = @rCmpId and Claim_ID = @rClaimId and For_Date = @rFromDate

		if @rClaimAppId = 0 and @flag <> 1
		Begin
			select @lApplicationAmount = SUM(isnull(Application_Amount,0))
			from T0110_CLAIM_APPLICATION_DETAIL CAD
			inner join T0100_CLAIM_APPLICATION ca on ca.claim_app_id=cad.claim_app_id
			inner join T0040_CLAIM_MASTER cm on cm.Claim_ID=cad.Claim_ID and cm.Cmp_ID=cad.Cmp_ID	
			where cad.Cmp_ID= @rCmpId and for_date between @rFromDate and @rFromDate and cm.Claim_ID=@rClaimId and ca.emp_id=@rEmpId and ca.Claim_App_Status='P'
			--and isnull(Claim_FamilyMeberId,0) = case when isnull(@rRowId,0) = 0 then 0 else @rRowId end
			and CAD.Claim_App_ID = @rClaimAppId
			--<> CASE WHEN isnull(@rClaimAppId,0) = 0 THEN 0 ELSE @rClaimAppId END
			
			select @lApprovalAmount = sum(isnull(cad.Claim_Apr_Amount,cad.Claim_App_Amount))
			from T0130_CLAIM_APPROVAL_DETAIL cad
			inner join T0120_CLAIM_APPROVAL ca on ca.Claim_Apr_ID=cad.Claim_Apr_ID
			inner join T0040_Claim_master cm on cm.Claim_ID=cad.Claim_ID and cm.Cmp_ID=cad.Cmp_ID	
			where cad.Cmp_ID=@rCmpId and cad.Claim_Apr_Date between @rFromDate and @rFromDate and cm.Claim_ID=@rClaimId and ca.emp_id=@rEmpId and cad.Claim_Status='A'
			--and isnull(Claim_FamilyMeberId,0) = case when isnull(@rRowId,0) = 0 then 0 else @rRowId end
			and CAD.Claim_App_ID = @rClaimAppId
			--<> CASE WHEN isnull(@rClaimAppId,0) = 0 THEN 0 ELSE @rClaimAppId END
		End
		Else
		Begin
			select @lApplicationAmount = SUM(isnull(Application_Amount,0))
			from T0110_CLAIM_APPLICATION_DETAIL CAD
			inner join T0100_CLAIM_APPLICATION ca on ca.claim_app_id=cad.claim_app_id
			inner join T0040_CLAIM_MASTER cm on cm.Claim_ID=cad.Claim_ID and cm.Cmp_ID=cad.Cmp_ID	
			where cad.Cmp_ID= @rCmpId and for_date between @rFromDate and @rFromDate and cm.Claim_ID=@rClaimId and ca.emp_id=@rEmpId and ca.Claim_App_Status='P'
			--and isnull(Claim_FamilyMeberId,0) = case when isnull(@rRowId,0) = 0 then 0 else @rRowId end
			and CAD.Claim_App_ID <> CASE WHEN isnull(@rClaimAppId,0) = 0 THEN 0 ELSE @rClaimAppId END	
	
			select @lApprovalAmount = sum(isnull(cad.Claim_Apr_Amount,cad.Claim_App_Amount))
			from T0130_CLAIM_APPROVAL_DETAIL cad
			inner join T0120_CLAIM_APPROVAL ca on ca.Claim_Apr_ID=cad.Claim_Apr_ID
			inner join T0040_Claim_master cm on cm.Claim_ID=cad.Claim_ID and cm.Cmp_ID=cad.Cmp_ID	
			where cad.Cmp_ID=@rCmpId and cad.Claim_Apr_Date between @rFromDate and @rFromDate and cm.Claim_ID=@rClaimId and ca.emp_id=@rEmpId and cad.Claim_Status='A'
			--and isnull(Claim_FamilyMeberId,0) = case when isnull(@rRowId,0) = 0 then 0 else @rRowId end
			and CAD.Claim_App_ID <> CASE WHEN isnull(@rClaimAppId,0) = 0 THEN 0 ELSE @rClaimAppId END
		End
	End
	else
	begin
			select @lApplicationAmount = SUM(isnull(Application_Amount,0))
		from T0110_CLAIM_APPLICATION_DETAIL CAD
		inner join T0100_CLAIM_APPLICATION ca on ca.claim_app_id=cad.claim_app_id
		inner join T0040_CLAIM_MASTER cm on cm.Claim_ID=cad.Claim_ID and cm.Cmp_ID=cad.Cmp_ID	
		where cad.Cmp_ID= @rCmpId and for_date between @lFirstDate and @lLastDate and cm.Claim_ID=@rClaimId and ca.emp_id=@rEmpId and ca.Claim_App_Status='P'
		and isnull(Claim_FamilyMeberId,0) = case when isnull(@rRowId,0) = 0 then 0 else @rRowId end
		and CAD.Claim_App_ID <> CASE WHEN isnull(@rClaimAppId,0) = 0 THEN 0 ELSE @rClaimAppId END
		
		select @lApprovalAmount = sum(isnull(cad.Claim_Apr_Amount,cad.Claim_App_Amount))
		from T0130_CLAIM_APPROVAL_DETAIL cad
		inner join T0120_CLAIM_APPROVAL ca on ca.Claim_Apr_ID=cad.Claim_Apr_ID
		inner join T0040_Claim_master cm on cm.Claim_ID=cad.Claim_ID and cm.Cmp_ID=cad.Cmp_ID	
		where cad.Cmp_ID=@rCmpId and cad.Claim_Apr_Date between @lFirstDate and @lLastDate and cm.Claim_ID=@rClaimId and ca.emp_id=@rEmpId and cad.Claim_Status='A'
		and isnull(Claim_FamilyMeberId,0) = case when isnull(@rRowId,0) = 0 then 0 else @rRowId end
		and CAD.Claim_App_ID <> CASE WHEN isnull(@rClaimAppId,0) = 0 THEN 0 ELSE @rClaimAppId END
	end
	
	select @lNewLimit = @Limit - (isnull(@lApplicationAmount,0) + isnull(@lApprovalAmount,0))

	if @lApplicableOnceBasedOnLimit = 1 and @lClaimLimitType in (1,2,3,4,5) and (@lApprovalAmount > 0 or @lApplicationAmount > 0)
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
	
	declare @chklimitlbl as tinyint 

	Select @chklimitlbl = isnull(Chklimitlbl,0)  from T0040_CLAIM_MASTER where Claim_ID = @rClaimId 

	if	@chklimitlbl = 1
	Begin
		select Claim_ID as ClaimID,@Limit as ClaimLimit,ISNULL(Grade_Wise_Limit,0) as GradeWiseLimit,ISNULL(Branch_Wise_Limit,0) as BranchWiseLimit,ISNULL(Desig_Wise_Limit,0) as DesignationWiseLimit,
		ISNULL(Gross_Salary_wise,0) as GrossSalaryWiseLimit,ISNULL(Basic_Salary_wise,0) as BasicSalaryWiseLimit,ISNULL(Claim_Def_Id,0) as ClaimDefId,ISNULL(Claim_Limit_Type,0) as ClaimLimitType,
		ISNULL(Claim_Main_Type,0) as ClaimMainType,ISNULL(CLAIM_ALLOW_BEYOND_LIMIT,0) as ClaimAllowBeyondLimit,ISNULL(For_Gender,0) as ForGender,ISNULL(Gender_Wise,0) as GenderWise,
		ISNULL(Applicable_Once,0) as ApplicableOnce,ISNULL(Age_Wise_Limit,0) as AgeWiseLimit,isnull(@lLimitFlag,0) as LimitFlag,isnull(@lAge,0) as Age,isnull(@lDays,0) as JoindateDays,
		isnull(@lCurrentMontDays,0) as CurrentMonthDays,isnull(@lNewLimit,0) as ConsiderationClaimLimit,isnull(Claim_Def_Id,0) as Claim_Def_Id,isnull(@lRatePerKM,0) as RatePerKM,
		isnull(Attach_Mandatory,0) as Attach_Mandatory,isnull(@lClaimType,0) as ClaimType,isnull(@lApplicationAmount,0) as ApplicationAmt,isnull(@lApprovalAmount,0) as ApprovalAmt,@lResult as Result,
		
		DateStr = 
		CASE Claim_Type WHEN 0 THEN '' + CASE YearBy WHEN 1 THEN 'Calender Year ' +
		CASE WHEN isnull((select tid from @tblDates where @rFromDate between t_StartDate and t_EndDate),0) <> 0 THEN
		(select convert(Varchar,YEAR(t_StartDate)) from @tblDates where @rFromDate between t_StartDate and t_EndDate) else (select convert(Varchar,YEAR(dateadd(year,1,t_StartDate))) from @tblDates
		where @rFromDate between dateadd(year,1,t_StartDate) and dateadd(year,1,t_EndDate)) end
		ELSE 'Financial Year ' + CASE WHEN isnull((select tid from @tblDates where @rFromDate between t_StartDate and t_EndDate),0) <> 0 THEN
		(select convert(Varchar,YEAR(t_StartDate)) + '-' + CONVERT(varchar,year(t_EndDate)) from @tblDates where @rFromDate between t_StartDate and t_EndDate) else
		(select convert(Varchar,YEAR(dateadd(year,1,t_StartDate))) + '-' + CONVERT(varchar,YEAR(dateadd(year,1,t_EndDate))) from @tblDates
		where @rFromDate between dateadd(year,1,t_StartDate) and dateadd(year,1,t_EndDate))	end	END + '' ELSE '' END ,
		
		
		LimitSTR = CASE isnull(Claim_Limit_Type,0) when 0 then 'Daily' when 1 then 'Monthly' when 2 then 'Yearly' when 3 then 'Quarterly' END,	
		ClaimLimitStr = CASE Claim_Type WHEN 0 THEN '' + CASE WHEN isnull(Claim_Limit_Type,0) = 2 THEN 'Yearly Type : <b style="color:#55607e;">' + CASE YearBy WHEN 1 THEN 'Calender Year ' +
		CASE WHEN isnull((select tid from @tblDates where @rFromDate between t_StartDate and t_EndDate),0) <> 0 THEN
		(select convert(Varchar,YEAR(t_StartDate)) from @tblDates where @rFromDate between t_StartDate and t_EndDate) else (select convert(Varchar,YEAR(dateadd(year,1,t_StartDate))) from @tblDates
		where @rFromDate between dateadd(year,1,t_StartDate) and dateadd(year,1,t_EndDate)) end
		ELSE 'Financial Year ' + CASE WHEN isnull((select tid from @tblDates where @rFromDate between t_StartDate and t_EndDate),0) <> 0 THEN
		(select convert(Varchar,YEAR(t_StartDate)) + '-' + CONVERT(varchar,year(t_EndDate)) from @tblDates where @rFromDate between t_StartDate and t_EndDate) else
		(select convert(Varchar,YEAR(dateadd(year,1,t_StartDate))) + '-' + CONVERT(varchar,YEAR(dateadd(year,1,t_EndDate))) from @tblDates
		where @rFromDate between dateadd(year,1,t_StartDate) and dateadd(year,1,t_EndDate))	end	END + '</b>' ELSE '' END
		+ CASE WHEN isnull(Claim_Limit_Type,0) = 3 THEN
		CASE WHEN isnull((select tid from @tblDates where @rFromDate between t_StartDate and t_EndDate),0) <> 0 THEN
		', Quarter Range : <b style="color:#55607e;">(' + (select convert(Varchar,t_StartDate,103) + '-' + CONVERT(varchar,t_EndDate,103) + ' (Quarter ' + convert(varchar,tid) + ' )' from @tblDates where @rFromDate between t_StartDate and t_EndDate) + ')</b>'
		ELSE ', Quarter Range : <b style="color:#55607e;">(' + (select convert(Varchar,dateadd(year,1,t_StartDate),103) + '-' + CONVERT(varchar,dateadd(year,1,t_EndDate),103) + ' (Quarter ' + convert(varchar,tid) + ' )' from @tblDates
		where @rFromDate between dateadd(year,1,t_StartDate) and dateadd(year,1,t_EndDate)) + ')</b>' END
		ELSE '' END + CASE WHEN isnull(@lAfter_Joining_Days,0) > 0 THEN ', Eligible Limit: <b style="color:#55607e;">' + convert(Varchar,@lAfter_Joining_Days) + ' Days (' + convert(Varchar,(@lAfter_Joining_Days/365)) + ' Year)</b>' ELSE '' END
		+ CASE WHEN isnull(No_Of_Year_Limit,0) > 0 THEN ', Periodicaly: <b style="color:#55607e;">' + convert(Varchar,No_Of_Year_Limit) + ' Yearly</b>' ELSE '' END
		ELSE CASE WHEN @lRatePerKM > 0 and @lflagRateOrUnit = 0 THEN 'Claim Petrol Rate : <b style="color:#55607e;">' + convert(varchar,@lRatePerKM) + '</b>, '
		WHEN @lRatePerKM > 0 and @lflagRateOrUnit = 1 THEN + '</b> Cost per ' + @lUnitName + ' :
		<b style="color:#55607e;">' + convert(varchar,@lConversionRate) + '</b>, '	ELSE '' END + CASE WHEN @lMinKm > 0 THEN ' Min KM : <b style="color:#55607e;">' + CONVERT(varchar,@lMinKm) + '</b>,	' else '' end + '	
		<b style="color:#55607e;">&nbsp;(' + CASE isnull(Claim_Limit_Type,0) when 0 then 'Daily' when 1 then 'Monthly' when 2 then 'Yearly' when 3 then 'Quarterly' END + ')</b>' END,
		@lJoinDate as joinDate,@lReleaseMonth as ReleaseMonth,ISNULL(Claim_For,0) as ClaimFor,isnull(@lFamilyResult,'') as FamilyDetails,isnull(Claim_Terms_Condition,'') as TermsCondition,
		@lAfter_Joining_Days as AfterJoiningDays,@lAllowFlag as AllowFlag,@lflagRateOrUnit as UnitFlag,@lUnitName as UnitName,isnull(@lConversionRate,1) as ConversionRate,isnull(@lMinKm,0) as MinKm,isnull(YearBy,0) as YearBy,isnull(Application_Limitwise,0) as Application_Limitwise
		from T0040_CLAIM_MASTER where Claim_ID = @rClaimId
	ENd
	ELSe
	Begin
		select Claim_ID as ClaimID,@Limit as ClaimLimit,ISNULL(Grade_Wise_Limit,0) as GradeWiseLimit,ISNULL(Branch_Wise_Limit,0) as BranchWiseLimit,ISNULL(Desig_Wise_Limit,0) as DesignationWiseLimit,
		ISNULL(Gross_Salary_wise,0) as GrossSalaryWiseLimit,ISNULL(Basic_Salary_wise,0) as BasicSalaryWiseLimit,ISNULL(Claim_Def_Id,0) as ClaimDefId,ISNULL(Claim_Limit_Type,0) as ClaimLimitType,
		ISNULL(Claim_Main_Type,0) as ClaimMainType,ISNULL(CLAIM_ALLOW_BEYOND_LIMIT,0) as ClaimAllowBeyondLimit,ISNULL(For_Gender,0) as ForGender,ISNULL(Gender_Wise,0) as GenderWise,
		ISNULL(Applicable_Once,0) as ApplicableOnce,ISNULL(Age_Wise_Limit,0) as AgeWiseLimit,isnull(@lLimitFlag,0) as LimitFlag,isnull(@lAge,0) as Age,isnull(@lDays,0) as JoindateDays,
		isnull(@lCurrentMontDays,0) as CurrentMonthDays,isnull(@lNewLimit,0) as ConsiderationClaimLimit,isnull(Claim_Def_Id,0) as Claim_Def_Id,isnull(@lRatePerKM,0) as RatePerKM,
		isnull(Attach_Mandatory,0) as Attach_Mandatory,isnull(@lClaimType,0) as ClaimType,isnull(@lApplicationAmount,0) as ApplicationAmt,isnull(@lApprovalAmount,0) as ApprovalAmt,@lResult as Result,
		
		DateStr = 
		CASE Claim_Type WHEN 0 THEN '' + CASE YearBy WHEN 1 THEN 'Calender Year ' +
		CASE WHEN isnull((select tid from @tblDates where @rFromDate between t_StartDate and t_EndDate),0) <> 0 THEN
		(select convert(Varchar,YEAR(t_StartDate)) from @tblDates where @rFromDate between t_StartDate and t_EndDate) else (select convert(Varchar,YEAR(dateadd(year,1,t_StartDate))) from @tblDates
		where @rFromDate between dateadd(year,1,t_StartDate) and dateadd(year,1,t_EndDate)) end
		ELSE 'Financial Year ' + CASE WHEN isnull((select tid from @tblDates where @rFromDate between t_StartDate and t_EndDate),0) <> 0 THEN
		(select convert(Varchar,YEAR(t_StartDate)) + '-' + CONVERT(varchar,year(t_EndDate)) from @tblDates where @rFromDate between t_StartDate and t_EndDate) else
		(select convert(Varchar,YEAR(dateadd(year,1,t_StartDate))) + '-' + CONVERT(varchar,YEAR(dateadd(year,1,t_EndDate))) from @tblDates
		where @rFromDate between dateadd(year,1,t_StartDate) and dateadd(year,1,t_EndDate))	end	END + '' ELSE '' END,
		
		
		LimitSTR = CASE isnull(Claim_Limit_Type,0) when 0 then 'Daily' when 1 then 'Monthly' when 2 then 'Yearly' when 3 then 'Quarterly' END,	
		ClaimLimitStr = CASE Claim_Type WHEN 0 THEN 'Claim Max Amount : <b style="color:#55607e;">' + STR(@Limit,25,2) + '</b>
		<b style="color:#55607e;">&nbsp;(' + CASE isnull(Claim_Limit_Type,0) when 0 then 'Daily' when 1 then 'Monthly' when 2 then 'Yearly' when 3 then 'Quarterly' END + ')</b>'
		+ CASE WHEN isnull(Claim_Limit_Type,0) = 2 THEN ', Yearly Type : <b style="color:#55607e;">' + CASE YearBy WHEN 1 THEN 'Calender Year ' +
		CASE WHEN isnull((select tid from @tblDates where @rFromDate between t_StartDate and t_EndDate),0) <> 0 THEN
		(select convert(Varchar,YEAR(t_StartDate)) from @tblDates where @rFromDate between t_StartDate and t_EndDate) else (select convert(Varchar,YEAR(dateadd(year,1,t_StartDate))) from @tblDates
		where @rFromDate between dateadd(year,1,t_StartDate) and dateadd(year,1,t_EndDate)) end
		ELSE 'Financial Year ' + CASE WHEN isnull((select tid from @tblDates where @rFromDate between t_StartDate and t_EndDate),0) <> 0 THEN
		(select convert(Varchar,YEAR(t_StartDate)) + '-' + CONVERT(varchar,year(t_EndDate)) from @tblDates where @rFromDate between t_StartDate and t_EndDate) else
		(select convert(Varchar,YEAR(dateadd(year,1,t_StartDate))) + '-' + CONVERT(varchar,YEAR(dateadd(year,1,t_EndDate))) from @tblDates
		where @rFromDate between dateadd(year,1,t_StartDate) and dateadd(year,1,t_EndDate))	end	END + '</b>' ELSE '' END
		+ CASE WHEN isnull(Claim_Limit_Type,0) = 3 THEN
		CASE WHEN isnull((select tid from @tblDates where @rFromDate between t_StartDate and t_EndDate),0) <> 0 THEN
		', Quarter Range : <b style="color:#55607e;">(' + (select convert(Varchar,t_StartDate,103) + '-' + CONVERT(varchar,t_EndDate,103) + ' (Quarter ' + convert(varchar,tid) + ' )' from @tblDates where @rFromDate between t_StartDate and t_EndDate) + ')</b>'
		ELSE ', Quarter Range : <b style="color:#55607e;">(' + (select convert(Varchar,dateadd(year,1,t_StartDate),103) + '-' + CONVERT(varchar,dateadd(year,1,t_EndDate),103) + ' (Quarter ' + convert(varchar,tid) + ' )' from @tblDates
		where @rFromDate between dateadd(year,1,t_StartDate) and dateadd(year,1,t_EndDate)) + ')</b>' END
		ELSE '' END + CASE WHEN isnull(@lAfter_Joining_Days,0) > 0 THEN ', Eligible Limit: <b style="color:#55607e;">' + convert(Varchar,@lAfter_Joining_Days) + ' Days (' + convert(Varchar,(@lAfter_Joining_Days/365)) + ' Year)</b>' ELSE '' END
		+ CASE WHEN isnull(No_Of_Year_Limit,0) > 0 THEN ', Periodicaly: <b style="color:#55607e;">' + convert(Varchar,No_Of_Year_Limit) + ' Yearly</b>' ELSE '' END
		ELSE CASE WHEN @lRatePerKM > 0 and @lflagRateOrUnit = 0 THEN 'Claim Petrol Rate : <b style="color:#55607e;">' + convert(varchar,@lRatePerKM) + '</b>, '
		WHEN @lRatePerKM > 0 and @lflagRateOrUnit = 1 THEN 'Claim Max ' + @lUnitName + ' : <b style="color:#55607e;">' + convert(varchar,@lRatePerKM) + '</b>, Cost per ' + @lUnitName + ' :
		<b style="color:#55607e;">' + convert(varchar,@lConversionRate) + '</b>, '	ELSE '' END + CASE WHEN @lMinKm > 0 THEN ' Min KM : <b style="color:#55607e;">' + CONVERT(varchar,@lMinKm) + '</b>,	' else '' end + '	
		 Claim Max Amt : <b style="color:#55607e;">' + convert(varchar,@Limit) + '</b>
		<b style="color:#55607e;">&nbsp;(' + CASE isnull(Claim_Limit_Type,0) when 0 then 'Daily' when 1 then 'Monthly' when 2 then 'Yearly' when 3 then 'Quarterly' END + ')</b>' END,
		@lJoinDate as joinDate,@lReleaseMonth as ReleaseMonth,ISNULL(Claim_For,0) as ClaimFor,isnull(@lFamilyResult,'') as FamilyDetails,isnull(Claim_Terms_Condition,'') as TermsCondition,
		@lAfter_Joining_Days as AfterJoiningDays,@lAllowFlag as AllowFlag,@lflagRateOrUnit as UnitFlag,@lUnitName as UnitName,isnull(@lConversionRate,1) as ConversionRate,isnull(@lMinKm,0) as MinKm,isnull(YearBy,0) as YearBy,isnull(Application_Limitwise,0) as Application_Limitwise
		from T0040_CLAIM_MASTER where Claim_ID = @rClaimId
	END

	
END