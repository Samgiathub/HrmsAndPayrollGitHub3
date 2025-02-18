using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0010CompanyMaster
{
    public decimal CmpId { get; set; }

    public string CmpName { get; set; } = null!;

    public string CmpAddress { get; set; } = null!;

    public decimal? LocId { get; set; }

    public string CmpCity { get; set; } = null!;

    public string CmpPinCode { get; set; } = null!;

    public string CmpPhone { get; set; } = null!;

    public string CmpEmail { get; set; } = null!;

    public string? CmpWeb { get; set; }

    public string DateFormat { get; set; } = null!;

    public DateTime FromDate { get; set; }

    public DateTime ToDate { get; set; }

    public string? PfNo { get; set; }

    public string? EsicNo { get; set; }

    public string? DomainName { get; set; }

    public string? ImageName { get; set; }

    public string? DefaultHoliday { get; set; }

    public string? CmpType { get; set; }

    public string? CmpStateName { get; set; }

    public string? CmpHrManager { get; set; }

    public string? CmpHrManagerDesig { get; set; }

    public string? CmpHrAssistant { get; set; }

    public string? CmpHrAssistantDesig { get; set; }

    public string? CmpPanNo { get; set; }

    public string? CmpTanNo { get; set; }

    public string? DatabaseFileName { get; set; }

    public byte? IsOrganiseChart { get; set; }

    public string? ImageFilePath { get; set; }

    public string? CmpCode { get; set; }

    public byte IsAutoAlphaNumericCode { get; set; }

    public decimal NoOfDigitEmpCode { get; set; }

    public string? CmpSignature { get; set; }

    public byte? IsGroupOfcmp { get; set; }

    public byte? IsMain { get; set; }

    public byte? IsOrganoDesignationwise { get; set; }

    public string? NatureOfBusiness { get; set; }

    public string? RegistrationNo { get; set; }

    public string? LicenseNo { get; set; }

    public string? NicCodeNo { get; set; }

    public DateTime? DateOfEstablishment { get; set; }

    public string? FactoryType { get; set; }

    public string? IncomeTaxNo { get; set; }

    public string? PfOffice { get; set; }

    public string? EsicOffice { get; set; }

    public string? TaxManagerForm16 { get; set; }

    public string? FatherNameForm16 { get; set; }

    public string? DesignationManagerForm16 { get; set; }

    public byte[]? CmpLogo { get; set; }

    public decimal InoutDuration { get; set; }

    public byte IsAlphaNumericBranchwise { get; set; }

    public byte IsContractorCompany { get; set; }

    public decimal IsPfApplicable { get; set; }

    public decimal IsEsicApplicable { get; set; }

    public string? CitAddress { get; set; }

    public string? CitCity { get; set; }

    public decimal? CitPin { get; set; }

    public byte? HasDigitalCerti { get; set; }

    public string? DigitalCertiFileName { get; set; }

    public string? DigitalCertiPassword { get; set; }

    public DateTime? DateForm16Submit { get; set; }

    public string? LicenseOffice { get; set; }

    public byte IsCompanyWise { get; set; }

    public byte IsDateWise { get; set; }

    public byte IsJoiningDateWise { get; set; }

    public string? DateFormat1 { get; set; }

    public byte? ResetSequance { get; set; }

    public string MaxEmpCode { get; set; } = null!;

    public string? SampleEmpCode { get; set; }

    public byte IsDesig { get; set; }

    public byte IsCate { get; set; }

    public byte IsEmpType { get; set; }

    public byte IsDateofBirth { get; set; }

    public byte IsCurrentDate { get; set; }

    public string? DateFormatBirth { get; set; }

    public string? DateFormatCurrent { get; set; }

    public string? CmpAccountNo { get; set; }

    public decimal IsActive { get; set; }

    public decimal? StateId { get; set; }

    public byte LeaveBalanceDisplayFixOpening { get; set; }

    public string? PfTrustNo { get; set; }

    public string? AltWName { get; set; }

    public string? AltWFullDayCont { get; set; }

    public string? CmpHeader { get; set; }

    public string? CmpFooter { get; set; }

    public byte Gst { get; set; }

    public string? GstNo { get; set; }

    public string? GstCmpName { get; set; }

    public string? LwfNumber { get; set; }

    public string? PasswordVerification { get; set; }

    public virtual ICollection<EmpForFnfAllowance> EmpForFnfAllowances { get; set; } = new List<EmpForFnfAllowance>();

    public virtual ICollection<MonthlyEmpBankPayment> MonthlyEmpBankPayments { get; set; } = new List<MonthlyEmpBankPayment>();

    public virtual ICollection<T0010CompanyDirectorDetail> T0010CompanyDirectorDetails { get; set; } = new List<T0010CompanyDirectorDetail>();

    public virtual ICollection<T0010HrCompReq> T0010HrCompReqs { get; set; } = new List<T0010HrCompReq>();

    public virtual ICollection<T0010SentEmail> T0010SentEmails { get; set; } = new List<T0010SentEmail>();

    public virtual ICollection<T0011CompanyMdDetail> T0011CompanyMdDetails { get; set; } = new List<T0011CompanyMdDetail>();

    public virtual ICollection<T0011LoginHistory> T0011LoginHistories { get; set; } = new List<T0011LoginHistory>();

    public virtual ICollection<T0011Login> T0011Logins { get; set; } = new List<T0011Login>();

    public virtual ICollection<T0011OtpTransaction> T0011OtpTransactions { get; set; } = new List<T0011OtpTransaction>();

    public virtual ICollection<T0011PasswordSetting> T0011PasswordSettings { get; set; } = new List<T0011PasswordSetting>();

    public virtual ICollection<T0012CompanyCrtLoginMaster> T0012CompanyCrtLoginMasters { get; set; } = new List<T0012CompanyCrtLoginMaster>();

    public virtual ICollection<T0015LoginBranchRight> T0015LoginBranchRights { get; set; } = new List<T0015LoginBranchRight>();

    public virtual ICollection<T0015LoginDetail> T0015LoginDetails { get; set; } = new List<T0015LoginDetail>();

    public virtual ICollection<T0015LoginFormRight> T0015LoginFormRights { get; set; } = new List<T0015LoginFormRight>();

    public virtual ICollection<T0015LoginRight> T0015LoginRights { get; set; } = new List<T0015LoginRight>();

    public virtual ICollection<T0020CompanyTransaction> T0020CompanyTransactions { get; set; } = new List<T0020CompanyTransaction>();

    public virtual ICollection<T0030AssetInstallation> T0030AssetInstallations { get; set; } = new List<T0030AssetInstallation>();

    public virtual ICollection<T0030BranchMaster> T0030BranchMasters { get; set; } = new List<T0030BranchMaster>();

    public virtual ICollection<T0030CategoryMaster> T0030CategoryMasters { get; set; } = new List<T0030CategoryMaster>();

    public virtual ICollection<T0030HrmsRatingMaster> T0030HrmsRatingMasters { get; set; } = new List<T0030HrmsRatingMaster>();

    public virtual ICollection<T0030HrmsTrainingType> T0030HrmsTrainingTypes { get; set; } = new List<T0030HrmsTrainingType>();

    public virtual ICollection<T0030TravelModeMaster> T0030TravelModeMasters { get; set; } = new List<T0030TravelModeMaster>();

    public virtual ICollection<T0040AchievementMaster> T0040AchievementMasters { get; set; } = new List<T0040AchievementMaster>();

    public virtual ICollection<T0040AdFormulaSetting> T0040AdFormulaSettings { get; set; } = new List<T0040AdFormulaSetting>();

    public virtual ICollection<T0040AdSlabSetting> T0040AdSlabSettings { get; set; } = new List<T0040AdSlabSetting>();

    public virtual ICollection<T0040AssetMaster> T0040AssetMasters { get; set; } = new List<T0040AssetMaster>();

    public virtual ICollection<T0040AttributeMaster> T0040AttributeMasters { get; set; } = new List<T0040AttributeMaster>();

    public virtual ICollection<T0040BrandMaster> T0040BrandMasters { get; set; } = new List<T0040BrandMaster>();

    public virtual ICollection<T0040BusinessSegment> T0040BusinessSegments { get; set; } = new List<T0040BusinessSegment>();

    public virtual ICollection<T0040ClaimMaster> T0040ClaimMasters { get; set; } = new List<T0040ClaimMaster>();

    public virtual ICollection<T0040CostCategory> T0040CostCategories { get; set; } = new List<T0040CostCategory>();

    public virtual ICollection<T0040CostCenterMaster> T0040CostCenterMasters { get; set; } = new List<T0040CostCenterMaster>();

    public virtual ICollection<T0040CostCenter> T0040CostCenters { get; set; } = new List<T0040CostCenter>();

    public virtual ICollection<T0040CurrencyMaster> T0040CurrencyMasters { get; set; } = new List<T0040CurrencyMaster>();

    public virtual ICollection<T0040DepartmentMaster> T0040DepartmentMasters { get; set; } = new List<T0040DepartmentMaster>();

    public virtual ICollection<T0040DesignationMaster> T0040DesignationMasters { get; set; } = new List<T0040DesignationMaster>();

    public virtual ICollection<T0040DocumentMaster> T0040DocumentMasters { get; set; } = new List<T0040DocumentMaster>();

    public virtual ICollection<T0040EmailNotificationConfig> T0040EmailNotificationConfigs { get; set; } = new List<T0040EmailNotificationConfig>();

    public virtual ICollection<T0040EmpKpiMaster> T0040EmpKpiMasters { get; set; } = new List<T0040EmpKpiMaster>();

    public virtual ICollection<T0040EmployeeRating> T0040EmployeeRatings { get; set; } = new List<T0040EmployeeRating>();

    public virtual ICollection<T0040EventMaster> T0040EventMasters { get; set; } = new List<T0040EventMaster>();

    public virtual ICollection<T0040FormMaster> T0040FormMasters { get; set; } = new List<T0040FormMaster>();

    public virtual ICollection<T0040FunctionalMaster> T0040FunctionalMasters { get; set; } = new List<T0040FunctionalMaster>();

    public virtual ICollection<T0040GradeMaster> T0040GradeMasters { get; set; } = new List<T0040GradeMaster>();

    public virtual ICollection<T0040HolidayMaster> T0040HolidayMasters { get; set; } = new List<T0040HolidayMaster>();

    public virtual ICollection<T0040HrDocMaster> T0040HrDocMasters { get; set; } = new List<T0040HrDocMaster>();

    public virtual ICollection<T0040HrmsAttributeMaster> T0040HrmsAttributeMasters { get; set; } = new List<T0040HrmsAttributeMaster>();

    public virtual ICollection<T0040HrmsAwardMaster> T0040HrmsAwardMasters { get; set; } = new List<T0040HrmsAwardMaster>();

    public virtual ICollection<T0040HrmsGeneralSetting> T0040HrmsGeneralSettings { get; set; } = new List<T0040HrmsGeneralSetting>();

    public virtual ICollection<T0040HrmsGoalMaster> T0040HrmsGoalMasters { get; set; } = new List<T0040HrmsGoalMaster>();

    public virtual ICollection<T0040HrmsRangeMaster> T0040HrmsRangeMasters { get; set; } = new List<T0040HrmsRangeMaster>();

    public virtual ICollection<T0040HrmsRewardValue> T0040HrmsRewardValues { get; set; } = new List<T0040HrmsRewardValue>();

    public virtual ICollection<T0040HrmsTrainingMaster> T0040HrmsTrainingMasters { get; set; } = new List<T0040HrmsTrainingMaster>();

    public virtual ICollection<T0040InsuranceMaster> T0040InsuranceMasters { get; set; } = new List<T0040InsuranceMaster>();

    public virtual ICollection<T0040IpMaster> T0040IpMasters { get; set; } = new List<T0040IpMaster>();

    public virtual ICollection<T0040ItDeduction> T0040ItDeductions { get; set; } = new List<T0040ItDeduction>();

    public virtual ICollection<T0040KpiAlertSetting> T0040KpiAlertSettings { get; set; } = new List<T0040KpiAlertSetting>();

    public virtual ICollection<T0040KpiMaster> T0040KpiMasters { get; set; } = new List<T0040KpiMaster>();

    public virtual ICollection<T0040LanguageMaster> T0040LanguageMasters { get; set; } = new List<T0040LanguageMaster>();

    public virtual ICollection<T0040LateExtraAmount> T0040LateExtraAmounts { get; set; } = new List<T0040LateExtraAmount>();

    public virtual ICollection<T0040LicenseMaster> T0040LicenseMasters { get; set; } = new List<T0040LicenseMaster>();

    public virtual ICollection<T0040LoanMaster> T0040LoanMasters { get; set; } = new List<T0040LoanMaster>();

    public virtual ICollection<T0040NewsLetterMaster> T0040NewsLetterMasters { get; set; } = new List<T0040NewsLetterMaster>();

    public virtual ICollection<T0040OverHeadMaster> T0040OverHeadMasters { get; set; } = new List<T0040OverHeadMaster>();

    public virtual ICollection<T0040PerformanceFeedbackMaster> T0040PerformanceFeedbackMasters { get; set; } = new List<T0040PerformanceFeedbackMaster>();

    public virtual ICollection<T0040PerformanceIncentiveMaster> T0040PerformanceIncentiveMasters { get; set; } = new List<T0040PerformanceIncentiveMaster>();

    public virtual ICollection<T0040ProductMaster> T0040ProductMasters { get; set; } = new List<T0040ProductMaster>();

    public virtual ICollection<T0040ProfessionalSetting> T0040ProfessionalSettings { get; set; } = new List<T0040ProfessionalSetting>();

    public virtual ICollection<T0040ProjectMaster> T0040ProjectMasters { get; set; } = new List<T0040ProjectMaster>();

    public virtual ICollection<T0040ProjectStatus> T0040ProjectStatuses { get; set; } = new List<T0040ProjectStatus>();

    public virtual ICollection<T0040QualificationMaster> T0040QualificationMasters { get; set; } = new List<T0040QualificationMaster>();

    public virtual ICollection<T0040RatingMaster> T0040RatingMasters { get; set; } = new List<T0040RatingMaster>();

    public virtual ICollection<T0040ReimClaimSetting> T0040ReimClaimSettings { get; set; } = new List<T0040ReimClaimSetting>();

    public virtual ICollection<T0040SalaryCycleMaster> T0040SalaryCycleMasters { get; set; } = new List<T0040SalaryCycleMaster>();

    public virtual ICollection<T0040SchemeMaster> T0040SchemeMasters { get; set; } = new List<T0040SchemeMaster>();

    public virtual ICollection<T0040SelfAppraisalMaster> T0040SelfAppraisalMasters { get; set; } = new List<T0040SelfAppraisalMaster>();

    public virtual ICollection<T0040SettingDisplayField> T0040SettingDisplayFields { get; set; } = new List<T0040SettingDisplayField>();

    public virtual ICollection<T0040ShiftMaster> T0040ShiftMasters { get; set; } = new List<T0040ShiftMaster>();

    public virtual ICollection<T0040SignatureMaster> T0040SignatureMasters { get; set; } = new List<T0040SignatureMaster>();

    public virtual ICollection<T0040SkillMaster> T0040SkillMasters { get; set; } = new List<T0040SkillMaster>();

    public virtual ICollection<T0040SmsSetting> T0040SmsSettings { get; set; } = new List<T0040SmsSetting>();

    public virtual ICollection<T0040SpecialityMaster> T0040SpecialityMasters { get; set; } = new List<T0040SpecialityMaster>();

    public virtual ICollection<T0040SubProductMaster> T0040SubProductMasters { get; set; } = new List<T0040SubProductMaster>();

    public virtual ICollection<T0040SurveyQuestBank> T0040SurveyQuestBanks { get; set; } = new List<T0040SurveyQuestBank>();

    public virtual ICollection<T0040TallyLedMaster> T0040TallyLedMasters { get; set; } = new List<T0040TallyLedMaster>();

    public virtual ICollection<T0040TaskMaster> T0040TaskMasters { get; set; } = new List<T0040TaskMaster>();

    public virtual ICollection<T0040TaxLimit> T0040TaxLimits { get; set; } = new List<T0040TaxLimit>();

    public virtual ICollection<T0040TrainingInductionMaster> T0040TrainingInductionMasters { get; set; } = new List<T0040TrainingInductionMaster>();

    public virtual ICollection<T0040TsProjectMaster> T0040TsProjectMasters { get; set; } = new List<T0040TsProjectMaster>();

    public virtual ICollection<T0040TypeMaster> T0040TypeMasters { get; set; } = new List<T0040TypeMaster>();

    public virtual ICollection<T0040VacancyMaster> T0040VacancyMasters { get; set; } = new List<T0040VacancyMaster>();

    public virtual ICollection<T0040VerticalSegment> T0040VerticalSegments { get; set; } = new List<T0040VerticalSegment>();

    public virtual ICollection<T0040WarningMaster> T0040WarningMasters { get; set; } = new List<T0040WarningMaster>();

    public virtual ICollection<T0040WeekoffMaster> T0040WeekoffMasters { get; set; } = new List<T0040WeekoffMaster>();

    public virtual ICollection<T0040WorkMaster> T0040WorkMasters { get; set; } = new List<T0040WorkMaster>();

    public virtual ICollection<T0045HrmsRProcessTemplate> T0045HrmsRProcessTemplates { get; set; } = new List<T0045HrmsRProcessTemplate>();

    public virtual ICollection<T0050AdExpenseLimitMaster> T0050AdExpenseLimitMasters { get; set; } = new List<T0050AdExpenseLimitMaster>();

    public virtual ICollection<T0050AdExpenseLimit> T0050AdExpenseLimits { get; set; } = new List<T0050AdExpenseLimit>();

    public virtual ICollection<T0050AdMaster> T0050AdMasters { get; set; } = new List<T0050AdMaster>();

    public virtual ICollection<T0050AppraisalLimitSetting> T0050AppraisalLimitSettings { get; set; } = new List<T0050AppraisalLimitSetting>();

    public virtual ICollection<T0050AppraisalUtilitySetting> T0050AppraisalUtilitySettings { get; set; } = new List<T0050AppraisalUtilitySetting>();

    public virtual ICollection<T0050EmpSubProductDetail> T0050EmpSubProductDetails { get; set; } = new List<T0050EmpSubProductDetail>();

    public virtual ICollection<T0050ExpenseTypeMaxLimitCountry> T0050ExpenseTypeMaxLimitCountries { get; set; } = new List<T0050ExpenseTypeMaxLimitCountry>();

    public virtual ICollection<T0050ExpenseTypeMaxLimit> T0050ExpenseTypeMaxLimits { get; set; } = new List<T0050ExpenseTypeMaxLimit>();

    public virtual ICollection<T0050GeneralDetail> T0050GeneralDetails { get; set; } = new List<T0050GeneralDetail>();

    public virtual ICollection<T0050HrmsAppraisalSetting> T0050HrmsAppraisalSettings { get; set; } = new List<T0050HrmsAppraisalSetting>();

    public virtual ICollection<T0050HrmsEmpOaFeedback> T0050HrmsEmpOaFeedbacks { get; set; } = new List<T0050HrmsEmpOaFeedback>();

    public virtual ICollection<T0050HrmsInitiateAppraisal> T0050HrmsInitiateAppraisals { get; set; } = new List<T0050HrmsInitiateAppraisal>();

    public virtual ICollection<T0050HrmsRangeDeptAllocation> T0050HrmsRangeDeptAllocations { get; set; } = new List<T0050HrmsRangeDeptAllocation>();

    public virtual ICollection<T0050HrmsRecruitmentRequest> T0050HrmsRecruitmentRequests { get; set; } = new List<T0050HrmsRecruitmentRequest>();

    public virtual ICollection<T0050HrmsSkillRateSetting> T0050HrmsSkillRateSettings { get; set; } = new List<T0050HrmsSkillRateSetting>();

    public virtual ICollection<T0050HrmsTrainingProviderMaster> T0050HrmsTrainingProviderMasters { get; set; } = new List<T0050HrmsTrainingProviderMaster>();

    public virtual ICollection<T0050JobDescriptionMaster> T0050JobDescriptionMasters { get; set; } = new List<T0050JobDescriptionMaster>();

    public virtual ICollection<T0050KpiIncrementRange> T0050KpiIncrementRanges { get; set; } = new List<T0050KpiIncrementRange>();

    public virtual ICollection<T0050LeaveCfMonthlySetting> T0050LeaveCfMonthlySettings { get; set; } = new List<T0050LeaveCfMonthlySetting>();

    public virtual ICollection<T0050LeaveCfSetting> T0050LeaveCfSettings { get; set; } = new List<T0050LeaveCfSetting>();

    public virtual ICollection<T0050LeaveDetail> T0050LeaveDetails { get; set; } = new List<T0050LeaveDetail>();

    public virtual ICollection<T0050OptionalHolidayLimit> T0050OptionalHolidayLimits { get; set; } = new List<T0050OptionalHolidayLimit>();

    public virtual ICollection<T0050PrivilegeDetail> T0050PrivilegeDetails { get; set; } = new List<T0050PrivilegeDetail>();

    public virtual ICollection<T0050SaSubCriterion> T0050SaSubCriteria { get; set; } = new List<T0050SaSubCriterion>();

    public virtual ICollection<T0050SchemeDetail> T0050SchemeDetails { get; set; } = new List<T0050SchemeDetail>();

    public virtual ICollection<T0050ShiftDetail> T0050ShiftDetails { get; set; } = new List<T0050ShiftDetail>();

    public virtual ICollection<T0050SubBranch> T0050SubBranches { get; set; } = new List<T0050SubBranch>();

    public virtual ICollection<T0050SubVertical> T0050SubVerticals { get; set; } = new List<T0050SubVertical>();

    public virtual ICollection<T0050SurveyMaster> T0050SurveyMasters { get; set; } = new List<T0050SurveyMaster>();

    public virtual ICollection<T0050TaskDetail> T0050TaskDetails { get; set; } = new List<T0050TaskDetail>();

    public virtual ICollection<T0050TrainingInstituteMaster> T0050TrainingInstituteMasters { get; set; } = new List<T0050TrainingInstituteMaster>();

    public virtual ICollection<T0050TrainingLocationMaster> T0050TrainingLocationMasters { get; set; } = new List<T0050TrainingLocationMaster>();

    public virtual ICollection<T0051KpaMaster> T0051KpaMasters { get; set; } = new List<T0051KpaMaster>();

    public virtual ICollection<T0051SchemeDetailHistory> T0051SchemeDetailHistories { get; set; } = new List<T0051SchemeDetailHistory>();

    public virtual ICollection<T0052BscAlertSetting> T0052BscAlertSettings { get; set; } = new List<T0052BscAlertSetting>();

    public virtual ICollection<T0052EmpSelfAppraisal> T0052EmpSelfAppraisals { get; set; } = new List<T0052EmpSelfAppraisal>();

    public virtual ICollection<T0052HrmsAppTrainDetail> T0052HrmsAppTrainDetails { get; set; } = new List<T0052HrmsAppTrainDetail>();

    public virtual ICollection<T0052HrmsAppTrainingDetail> T0052HrmsAppTrainingDetails { get; set; } = new List<T0052HrmsAppTrainingDetail>();

    public virtual ICollection<T0052HrmsAppTraining> T0052HrmsAppTrainings { get; set; } = new List<T0052HrmsAppTraining>();

    public virtual ICollection<T0052HrmsAttributeFeedback> T0052HrmsAttributeFeedbacks { get; set; } = new List<T0052HrmsAttributeFeedback>();

    public virtual ICollection<T0052HrmsInitiateReward> T0052HrmsInitiateRewards { get; set; } = new List<T0052HrmsInitiateReward>();

    public virtual ICollection<T0052HrmsKpa> T0052HrmsKpas { get; set; } = new List<T0052HrmsKpa>();

    public virtual ICollection<T0052HrmsPerformanceAnswer> T0052HrmsPerformanceAnswers { get; set; } = new List<T0052HrmsPerformanceAnswer>();

    public virtual ICollection<T0052HrmsPostedRecruitment> T0052HrmsPostedRecruitments { get; set; } = new List<T0052HrmsPostedRecruitment>();

    public virtual ICollection<T0052HrmsRecruitmentRequestApproval> T0052HrmsRecruitmentRequestApprovals { get; set; } = new List<T0052HrmsRecruitmentRequestApproval>();

    public virtual ICollection<T0052HrmsTrainingCalenderYearly> T0052HrmsTrainingCalenderYearlies { get; set; } = new List<T0052HrmsTrainingCalenderYearly>();

    public virtual ICollection<T0052IncrementUtility> T0052IncrementUtilities { get; set; } = new List<T0052IncrementUtility>();

    public virtual ICollection<T0052ResumeFinalApproval> T0052ResumeFinalApprovals { get; set; } = new List<T0052ResumeFinalApproval>();

    public virtual ICollection<T0052SurveyTemplate> T0052SurveyTemplates { get; set; } = new List<T0052SurveyTemplate>();

    public virtual ICollection<T0053HrmsRecruitmentForm> T0053HrmsRecruitmentForms { get; set; } = new List<T0053HrmsRecruitmentForm>();

    public virtual ICollection<T0055HrmsEmpSkillDetail> T0055HrmsEmpSkillDetails { get; set; } = new List<T0055HrmsEmpSkillDetail>();

    public virtual ICollection<T0055HrmsInitiateKpasetting> T0055HrmsInitiateKpasettings { get; set; } = new List<T0055HrmsInitiateKpasetting>();

    public virtual ICollection<T0055HrmsInterviewScheduleHistory> T0055HrmsInterviewScheduleHistories { get; set; } = new List<T0055HrmsInterviewScheduleHistory>();

    public virtual ICollection<T0055HrmsInterviewSchedule> T0055HrmsInterviewSchedules { get; set; } = new List<T0055HrmsInterviewSchedule>();

    public virtual ICollection<T0055InterviewProcessDetail> T0055InterviewProcessDetails { get; set; } = new List<T0055InterviewProcessDetail>();

    public virtual ICollection<T0055InterviewProcessQuestionDetail> T0055InterviewProcessQuestionDetails { get; set; } = new List<T0055InterviewProcessQuestionDetail>();

    public virtual ICollection<T0055JobDocument> T0055JobDocuments { get; set; } = new List<T0055JobDocument>();

    public virtual ICollection<T0055JobResponsibility> T0055JobResponsibilities { get; set; } = new List<T0055JobResponsibility>();

    public virtual ICollection<T0055JobSkill> T0055JobSkills { get; set; } = new List<T0055JobSkill>();

    public virtual ICollection<T0055RecruitmentResponsibility> T0055RecruitmentResponsibilities { get; set; } = new List<T0055RecruitmentResponsibility>();

    public virtual ICollection<T0055RecruitmentSkill> T0055RecruitmentSkills { get; set; } = new List<T0055RecruitmentSkill>();

    public virtual ICollection<T0055Reimbursement> T0055Reimbursements { get; set; } = new List<T0055Reimbursement>();

    public virtual ICollection<T0055SkillGeneralSetting> T0055SkillGeneralSettings { get; set; } = new List<T0055SkillGeneralSetting>();

    public virtual ICollection<T0055TrainingFaculty> T0055TrainingFaculties { get; set; } = new List<T0055TrainingFaculty>();

    public virtual ICollection<T0060AppraisalEmpWeightage> T0060AppraisalEmpWeightages { get; set; } = new List<T0060AppraisalEmpWeightage>();

    public virtual ICollection<T0060AppraisalEmployeeKpa> T0060AppraisalEmployeeKpas { get; set; } = new List<T0060AppraisalEmployeeKpa>();

    public virtual ICollection<T0060EffectAdMaster> T0060EffectAdMasters { get; set; } = new List<T0060EffectAdMaster>();

    public virtual ICollection<T0060ExtraIncrementUtility> T0060ExtraIncrementUtilities { get; set; } = new List<T0060ExtraIncrementUtility>();

    public virtual ICollection<T0060HrmsEmployeeReward> T0060HrmsEmployeeRewards { get; set; } = new List<T0060HrmsEmployeeReward>();

    public virtual ICollection<T0060HrmsInterviewFeedbackDetail> T0060HrmsInterviewFeedbackDetails { get; set; } = new List<T0060HrmsInterviewFeedbackDetail>();

    public virtual ICollection<T0060ResumeFinal> T0060ResumeFinalAssignedCmps { get; set; } = new List<T0060ResumeFinal>();

    public virtual ICollection<T0060ResumeFinal> T0060ResumeFinalCmps { get; set; } = new List<T0060ResumeFinal>();

    public virtual ICollection<T0060RimbEffectAdMaster> T0060RimbEffectAdMasters { get; set; } = new List<T0060RimbEffectAdMaster>();

    public virtual ICollection<T0060SurveyEmployeeResponse> T0060SurveyEmployeeResponses { get; set; } = new List<T0060SurveyEmployeeResponse>();

    public virtual ICollection<T0070ItMaster> T0070ItMasters { get; set; } = new List<T0070ItMaster>();

    public virtual ICollection<T0080CostCenterDetail> T0080CostCenterDetails { get; set; } = new List<T0080CostCenterDetail>();

    public virtual ICollection<T0080EmpKpi> T0080EmpKpis { get; set; } = new List<T0080EmpKpi>();

    public virtual ICollection<T0080EmpMaster> T0080EmpMasters { get; set; } = new List<T0080EmpMaster>();

    public virtual ICollection<T0080KpiDevelopmentPlan> T0080KpiDevelopmentPlans { get; set; } = new List<T0080KpiDevelopmentPlan>();

    public virtual ICollection<T0080Kpiobjective> T0080Kpiobjectives { get; set; } = new List<T0080Kpiobjective>();

    public virtual ICollection<T0080KpipmsEval> T0080KpipmsEvals { get; set; } = new List<T0080KpipmsEval>();

    public virtual ICollection<T0080Kpirating> T0080Kpiratings { get; set; } = new List<T0080Kpirating>();

    public virtual ICollection<T0080SubKpiMaster> T0080SubKpiMasters { get; set; } = new List<T0080SubKpiMaster>();

    public virtual ICollection<T0090AdvancePaymentApproval> T0090AdvancePaymentApprovals { get; set; } = new List<T0090AdvancePaymentApproval>();

    public virtual ICollection<T0090AppMaster> T0090AppMasters { get; set; } = new List<T0090AppMaster>();

    public virtual ICollection<T0090BalanceScoreCardSetting> T0090BalanceScoreCardSettings { get; set; } = new List<T0090BalanceScoreCardSetting>();

    public virtual ICollection<T0090CommonRequestDetail> T0090CommonRequestDetails { get; set; } = new List<T0090CommonRequestDetail>();

    public virtual ICollection<T0090DevelopmentPlanningTemplate> T0090DevelopmentPlanningTemplates { get; set; } = new List<T0090DevelopmentPlanningTemplate>();

    public virtual ICollection<T0090EmpAssetDetail> T0090EmpAssetDetails { get; set; } = new List<T0090EmpAssetDetail>();

    public virtual ICollection<T0090EmpChildranDetail> T0090EmpChildranDetails { get; set; } = new List<T0090EmpChildranDetail>();

    public virtual ICollection<T0090EmpContractDetail> T0090EmpContractDetails { get; set; } = new List<T0090EmpContractDetail>();

    public virtual ICollection<T0090EmpDependantDetail> T0090EmpDependantDetails { get; set; } = new List<T0090EmpDependantDetail>();

    public virtual ICollection<T0090EmpDocDetail> T0090EmpDocDetails { get; set; } = new List<T0090EmpDocDetail>();

    public virtual ICollection<T0090EmpEmergencyContactDetail> T0090EmpEmergencyContactDetails { get; set; } = new List<T0090EmpEmergencyContactDetail>();

    public virtual ICollection<T0090EmpEvaluationDetail> T0090EmpEvaluationDetails { get; set; } = new List<T0090EmpEvaluationDetail>();

    public virtual ICollection<T0090EmpExperienceDetail> T0090EmpExperienceDetails { get; set; } = new List<T0090EmpExperienceDetail>();

    public virtual ICollection<T0090EmpGoalDetail> T0090EmpGoalDetails { get; set; } = new List<T0090EmpGoalDetail>();

    public virtual ICollection<T0090EmpHrDocDetail> T0090EmpHrDocDetails { get; set; } = new List<T0090EmpHrDocDetail>();

    public virtual ICollection<T0090EmpImmigrationDetail> T0090EmpImmigrationDetails { get; set; } = new List<T0090EmpImmigrationDetail>();

    public virtual ICollection<T0090EmpInsuranceDetail> T0090EmpInsuranceDetails { get; set; } = new List<T0090EmpInsuranceDetail>();

    public virtual ICollection<T0090EmpJdResponsibilty> T0090EmpJdResponsibilties { get; set; } = new List<T0090EmpJdResponsibilty>();

    public virtual ICollection<T0090EmpKpiApproval> T0090EmpKpiApprovals { get; set; } = new List<T0090EmpKpiApproval>();

    public virtual ICollection<T0090EmpLanguageDetail> T0090EmpLanguageDetails { get; set; } = new List<T0090EmpLanguageDetail>();

    public virtual ICollection<T0090EmpLicenseDetail> T0090EmpLicenseDetails { get; set; } = new List<T0090EmpLicenseDetail>();

    public virtual ICollection<T0090EmpMembershipDetail> T0090EmpMembershipDetails { get; set; } = new List<T0090EmpMembershipDetail>();

    public virtual ICollection<T0090EmpOtherDetail> T0090EmpOtherDetails { get; set; } = new List<T0090EmpOtherDetail>();

    public virtual ICollection<T0090EmpQualificationDetail> T0090EmpQualificationDetails { get; set; } = new List<T0090EmpQualificationDetail>();

    public virtual ICollection<T0090EmpReportingDetail> T0090EmpReportingDetails { get; set; } = new List<T0090EmpReportingDetail>();

    public virtual ICollection<T0090EmpSkillDetail> T0090EmpSkillDetails { get; set; } = new List<T0090EmpSkillDetail>();

    public virtual ICollection<T0090EmployeeGoalSetting> T0090EmployeeGoalSettings { get; set; } = new List<T0090EmployeeGoalSetting>();

    public virtual ICollection<T0090HrmsAppraisalInitiation> T0090HrmsAppraisalInitiations { get; set; } = new List<T0090HrmsAppraisalInitiation>();

    public virtual ICollection<T0090HrmsFinalScore> T0090HrmsFinalScores { get; set; } = new List<T0090HrmsFinalScore>();

    public virtual ICollection<T0090HrmsResumeBank> T0090HrmsResumeBanks { get; set; } = new List<T0090HrmsResumeBank>();

    public virtual ICollection<T0090HrmsResumeDocument> T0090HrmsResumeDocuments { get; set; } = new List<T0090HrmsResumeDocument>();

    public virtual ICollection<T0090HrmsResumeEarnDeduction> T0090HrmsResumeEarnDeductions { get; set; } = new List<T0090HrmsResumeEarnDeduction>();

    public virtual ICollection<T0090HrmsResumeExperience> T0090HrmsResumeExperiences { get; set; } = new List<T0090HrmsResumeExperience>();

    public virtual ICollection<T0090HrmsResumeHealth> T0090HrmsResumeHealths { get; set; } = new List<T0090HrmsResumeHealth>();

    public virtual ICollection<T0090HrmsResumeImmigration> T0090HrmsResumeImmigrations { get; set; } = new List<T0090HrmsResumeImmigration>();

    public virtual ICollection<T0090HrmsResumeNominee> T0090HrmsResumeNominees { get; set; } = new List<T0090HrmsResumeNominee>();

    public virtual ICollection<T0090HrmsResumeQualification> T0090HrmsResumeQualifications { get; set; } = new List<T0090HrmsResumeQualification>();

    public virtual ICollection<T0090HrmsResumeSkill> T0090HrmsResumeSkills { get; set; } = new List<T0090HrmsResumeSkill>();

    public virtual ICollection<T0090KpipmsEvalApproval> T0090KpipmsEvalApprovals { get; set; } = new List<T0090KpipmsEvalApproval>();

    public virtual ICollection<T0090KpipmsObjective> T0090KpipmsObjectives { get; set; } = new List<T0090KpipmsObjective>();

    public virtual ICollection<T0090PerformanceImprovementPlan> T0090PerformanceImprovementPlans { get; set; } = new List<T0090PerformanceImprovementPlan>();

    public virtual ICollection<T0090SubKpiMasterLevel> T0090SubKpiMasterLevels { get; set; } = new List<T0090SubKpiMasterLevel>();

    public virtual ICollection<T0090UniformRequisitionApplication> T0090UniformRequisitionApplications { get; set; } = new List<T0090UniformRequisitionApplication>();

    public virtual ICollection<T0091HrmsResumeHealthDetail> T0091HrmsResumeHealthDetails { get; set; } = new List<T0091HrmsResumeHealthDetail>();

    public virtual ICollection<T0095BalanceScoreCardEvaluation> T0095BalanceScoreCardEvaluations { get; set; } = new List<T0095BalanceScoreCardEvaluation>();

    public virtual ICollection<T0095BalanceScoreCardSettingDetail> T0095BalanceScoreCardSettingDetails { get; set; } = new List<T0095BalanceScoreCardSettingDetail>();

    public virtual ICollection<T0095DevelopmentPlanningTemplateDetail> T0095DevelopmentPlanningTemplateDetails { get; set; } = new List<T0095DevelopmentPlanningTemplateDetail>();

    public virtual ICollection<T0095EmpProbationMaster> T0095EmpProbationMasters { get; set; } = new List<T0095EmpProbationMaster>();

    public virtual ICollection<T0095EmpSchema> T0095EmpSchemas { get; set; } = new List<T0095EmpSchema>();

    public virtual ICollection<T0095EmpScheme> T0095EmpSchemes { get; set; } = new List<T0095EmpScheme>();

    public virtual ICollection<T0095EmployeeGoalSettingDetail> T0095EmployeeGoalSettingDetails { get; set; } = new List<T0095EmployeeGoalSettingDetail>();

    public virtual ICollection<T0095EmployeeGoalSettingEvaluation> T0095EmployeeGoalSettingEvaluations { get; set; } = new List<T0095EmployeeGoalSettingEvaluation>();

    public virtual ICollection<T0095HrmsCandidateScheme> T0095HrmsCandidateSchemes { get; set; } = new List<T0095HrmsCandidateScheme>();

    public virtual ICollection<T0095LeaveOpening> T0095LeaveOpenings { get; set; } = new List<T0095LeaveOpening>();

    public virtual ICollection<T0095PerformanceImprovementPlanDetail> T0095PerformanceImprovementPlanDetails { get; set; } = new List<T0095PerformanceImprovementPlanDetail>();

    public virtual ICollection<T0095ReimOpening> T0095ReimOpenings { get; set; } = new List<T0095ReimOpening>();

    public virtual ICollection<T0095UniformRequisitionApplicationDetail> T0095UniformRequisitionApplicationDetails { get; set; } = new List<T0095UniformRequisitionApplicationDetail>();

    public virtual ICollection<T0100AdvancePayment> T0100AdvancePayments { get; set; } = new List<T0100AdvancePayment>();

    public virtual ICollection<T0100AnualBonu> T0100AnualBonus { get; set; } = new List<T0100AnualBonu>();

    public virtual ICollection<T0100ArApplication> T0100ArApplications { get; set; } = new List<T0100ArApplication>();

    public virtual ICollection<T0100AssetApplication> T0100AssetApplications { get; set; } = new List<T0100AssetApplication>();

    public virtual ICollection<T0100BalanceScoreCardEvaluationDetail> T0100BalanceScoreCardEvaluationDetails { get; set; } = new List<T0100BalanceScoreCardEvaluationDetail>();

    public virtual ICollection<T0100BscScoringKey> T0100BscScoringKeys { get; set; } = new List<T0100BscScoringKey>();

    public virtual ICollection<T0100ClaimApplication> T0100ClaimApplications { get; set; } = new List<T0100ClaimApplication>();

    public virtual ICollection<T0100CompOffApplication> T0100CompOffApplications { get; set; } = new List<T0100CompOffApplication>();

    public virtual ICollection<T0100EmailDetail> T0100EmailDetails { get; set; } = new List<T0100EmailDetail>();

    public virtual ICollection<T0100EmpEarnDeduction> T0100EmpEarnDeductions { get; set; } = new List<T0100EmpEarnDeduction>();

    public virtual ICollection<T0100EmpGradeDetail> T0100EmpGradeDetails { get; set; } = new List<T0100EmpGradeDetail>();

    public virtual ICollection<T0100EmpKpiMasterLevel> T0100EmpKpiMasterLevels { get; set; } = new List<T0100EmpKpiMasterLevel>();

    public virtual ICollection<T0100EmpLateDetail> T0100EmpLateDetails { get; set; } = new List<T0100EmpLateDetail>();

    public virtual ICollection<T0100EmpLtaMedicalDetail> T0100EmpLtaMedicalDetails { get; set; } = new List<T0100EmpLtaMedicalDetail>();

    public virtual ICollection<T0100EmpManagerHistory> T0100EmpManagerHistories { get; set; } = new List<T0100EmpManagerHistory>();

    public virtual ICollection<T0100EmpPerformanceDetail> T0100EmpPerformanceDetails { get; set; } = new List<T0100EmpPerformanceDetail>();

    public virtual ICollection<T0100EmpProbationAttributeDetail> T0100EmpProbationAttributeDetails { get; set; } = new List<T0100EmpProbationAttributeDetail>();

    public virtual ICollection<T0100EmpProbationSkillDetail> T0100EmpProbationSkillDetails { get; set; } = new List<T0100EmpProbationSkillDetail>();

    public virtual ICollection<T0100EmpShiftDetail> T0100EmpShiftDetails { get; set; } = new List<T0100EmpShiftDetail>();

    public virtual ICollection<T0100EmpSkillAttrAssign> T0100EmpSkillAttrAssigns { get; set; } = new List<T0100EmpSkillAttrAssign>();

    public virtual ICollection<T0100EmployeeGoalSettingEvaluationDetail> T0100EmployeeGoalSettingEvaluationDetails { get; set; } = new List<T0100EmployeeGoalSettingEvaluationDetail>();

    public virtual ICollection<T0100EmployeeGoalSupEval> T0100EmployeeGoalSupEvals { get; set; } = new List<T0100EmployeeGoalSupEval>();

    public virtual ICollection<T0100GatePassApplication> T0100GatePassApplications { get; set; } = new List<T0100GatePassApplication>();

    public virtual ICollection<T0100Gratuity> T0100Gratuities { get; set; } = new List<T0100Gratuity>();

    public virtual ICollection<T0100HrmsCandidateSchemeLevel> T0100HrmsCandidateSchemeLevels { get; set; } = new List<T0100HrmsCandidateSchemeLevel>();

    public virtual ICollection<T0100HrmsResumeEarnDeductionLevel> T0100HrmsResumeEarnDeductionLevels { get; set; } = new List<T0100HrmsResumeEarnDeductionLevel>();

    public virtual ICollection<T0100HrmsTrainingApplication> T0100HrmsTrainingApplications { get; set; } = new List<T0100HrmsTrainingApplication>();

    public virtual ICollection<T0100ItDeclaration> T0100ItDeclarations { get; set; } = new List<T0100ItDeclaration>();

    public virtual ICollection<T0100ItFormDesign> T0100ItFormDesigns { get; set; } = new List<T0100ItFormDesign>();

    public virtual ICollection<T0100KpiDevelopmentPlanLevel> T0100KpiDevelopmentPlanLevels { get; set; } = new List<T0100KpiDevelopmentPlanLevel>();

    public virtual ICollection<T0100KpiobjectivesLevel> T0100KpiobjectivesLevels { get; set; } = new List<T0100KpiobjectivesLevel>();

    public virtual ICollection<T0100KpipmsObjectiveLevel> T0100KpipmsObjectiveLevels { get; set; } = new List<T0100KpipmsObjectiveLevel>();

    public virtual ICollection<T0100KpiratingLevel> T0100KpiratingLevels { get; set; } = new List<T0100KpiratingLevel>();

    public virtual ICollection<T0100LeaveApplication> T0100LeaveApplications { get; set; } = new List<T0100LeaveApplication>();

    public virtual ICollection<T0100LeaveCfDetail> T0100LeaveCfDetails { get; set; } = new List<T0100LeaveCfDetail>();

    public virtual ICollection<T0100LeaveEncashApplication> T0100LeaveEncashApplications { get; set; } = new List<T0100LeaveEncashApplication>();

    public virtual ICollection<T0100LeftEmp> T0100LeftEmps { get; set; } = new List<T0100LeftEmp>();

    public virtual ICollection<T0100LoanApplication> T0100LoanApplications { get; set; } = new List<T0100LoanApplication>();

    public virtual ICollection<T0100NightHaltApplication> T0100NightHaltApplications { get; set; } = new List<T0100NightHaltApplication>();

    public virtual ICollection<T0100OpHolidayApplication> T0100OpHolidayApplications { get; set; } = new List<T0100OpHolidayApplication>();

    public virtual ICollection<T0100ProjectAllocation> T0100ProjectAllocations { get; set; } = new List<T0100ProjectAllocation>();

    public virtual ICollection<T0100RcApplication> T0100RcApplications { get; set; } = new List<T0100RcApplication>();

    public virtual ICollection<T0100RimbursementDetail> T0100RimbursementDetails { get; set; } = new List<T0100RimbursementDetail>();

    public virtual ICollection<T0100TrainingApplication> T0100TrainingApplications { get; set; } = new List<T0100TrainingApplication>();

    public virtual ICollection<T0100TravelApplication> T0100TravelApplications { get; set; } = new List<T0100TravelApplication>();

    public virtual ICollection<T0100TsApplication> T0100TsApplications { get; set; } = new List<T0100TsApplication>();

    public virtual ICollection<T0100UniformRequisitionApproval> T0100UniformRequisitionApprovals { get; set; } = new List<T0100UniformRequisitionApproval>();

    public virtual ICollection<T0100WarningDetail> T0100WarningDetails { get; set; } = new List<T0100WarningDetail>();

    public virtual ICollection<T0100WeekoffAdj> T0100WeekoffAdjs { get; set; } = new List<T0100WeekoffAdj>();

    public virtual ICollection<T0110AssetApplicationDetail> T0110AssetApplicationDetails { get; set; } = new List<T0110AssetApplicationDetail>();

    public virtual ICollection<T0110AssetInstallationDetail> T0110AssetInstallationDetails { get; set; } = new List<T0110AssetInstallationDetail>();

    public virtual ICollection<T0110AssetTitleDetail> T0110AssetTitleDetails { get; set; } = new List<T0110AssetTitleDetail>();

    public virtual ICollection<T0110BalanceScoreCardEvaluationApproval> T0110BalanceScoreCardEvaluationApprovals { get; set; } = new List<T0110BalanceScoreCardEvaluationApproval>();

    public virtual ICollection<T0110BalanceScoreCardSettingApproval> T0110BalanceScoreCardSettingApprovals { get; set; } = new List<T0110BalanceScoreCardSettingApproval>();

    public virtual ICollection<T0110EmpEarnDeductionRevised> T0110EmpEarnDeductionReviseds { get; set; } = new List<T0110EmpEarnDeductionRevised>();

    public virtual ICollection<T0110EmpLeftJoinTran> T0110EmpLeftJoinTrans { get; set; } = new List<T0110EmpLeftJoinTran>();

    public virtual ICollection<T0110EmployeeGoalSettingApproval> T0110EmployeeGoalSettingApprovals { get; set; } = new List<T0110EmployeeGoalSettingApproval>();

    public virtual ICollection<T0110EmployeeGoalSettingEvaluationApproval> T0110EmployeeGoalSettingEvaluationApprovals { get; set; } = new List<T0110EmployeeGoalSettingEvaluationApproval>();

    public virtual ICollection<T0110GratuityDetail> T0110GratuityDetails { get; set; } = new List<T0110GratuityDetail>();

    public virtual ICollection<T0110RcDependantDetail> T0110RcDependantDetails { get; set; } = new List<T0110RcDependantDetail>();

    public virtual ICollection<T0110RcLtaTravelDetail> T0110RcLtaTravelDetails { get; set; } = new List<T0110RcLtaTravelDetail>();

    public virtual ICollection<T0110RcReimbursementDetail> T0110RcReimbursementDetails { get; set; } = new List<T0110RcReimbursementDetail>();

    public virtual ICollection<T0110TrainingInductionDetail> T0110TrainingInductionDetails { get; set; } = new List<T0110TrainingInductionDetail>();

    public virtual ICollection<T0110TravelAdvanceDetail> T0110TravelAdvanceDetails { get; set; } = new List<T0110TravelAdvanceDetail>();

    public virtual ICollection<T0110TravelApplicationDetail> T0110TravelApplicationDetails { get; set; } = new List<T0110TravelApplicationDetail>();

    public virtual ICollection<T0110TsApplicationDetail> T0110TsApplicationDetails { get; set; } = new List<T0110TsApplicationDetail>();

    public virtual ICollection<T0110UniformDispatchDetail> T0110UniformDispatchDetails { get; set; } = new List<T0110UniformDispatchDetail>();

    public virtual ICollection<T0115AttendanceReguLevelApproval> T0115AttendanceReguLevelApprovals { get; set; } = new List<T0115AttendanceReguLevelApproval>();

    public virtual ICollection<T0115BalanceScoreCardEvaluationDetailsLevel> T0115BalanceScoreCardEvaluationDetailsLevels { get; set; } = new List<T0115BalanceScoreCardEvaluationDetailsLevel>();

    public virtual ICollection<T0115BalanceScoreCardSettingDetailsLevel> T0115BalanceScoreCardSettingDetailsLevels { get; set; } = new List<T0115BalanceScoreCardSettingDetailsLevel>();

    public virtual ICollection<T0115BscScoringKeyLevel> T0115BscScoringKeyLevels { get; set; } = new List<T0115BscScoringKeyLevel>();

    public virtual ICollection<T0115ClaimLevelApprovalDetail> T0115ClaimLevelApprovalDetails { get; set; } = new List<T0115ClaimLevelApprovalDetail>();

    public virtual ICollection<T0115ClaimLevelApproval> T0115ClaimLevelApprovals { get; set; } = new List<T0115ClaimLevelApproval>();

    public virtual ICollection<T0115EmployeeGoalSettingDetailsLevel> T0115EmployeeGoalSettingDetailsLevels { get; set; } = new List<T0115EmployeeGoalSettingDetailsLevel>();

    public virtual ICollection<T0115EmployeeGoalSettingEvaluationDetailsLevel> T0115EmployeeGoalSettingEvaluationDetailsLevels { get; set; } = new List<T0115EmployeeGoalSettingEvaluationDetailsLevel>();

    public virtual ICollection<T0115EmployeeGoalSupEvalLevel> T0115EmployeeGoalSupEvalLevels { get; set; } = new List<T0115EmployeeGoalSupEvalLevel>();

    public virtual ICollection<T0115FileLevelApproval> T0115FileLevelApprovals { get; set; } = new List<T0115FileLevelApproval>();

    public virtual ICollection<T0115LeaveLevelApproval> T0115LeaveLevelApprovals { get; set; } = new List<T0115LeaveLevelApproval>();

    public virtual ICollection<T0115LoanLevelApproval> T0115LoanLevelApprovals { get; set; } = new List<T0115LoanLevelApproval>();

    public virtual ICollection<T0115RcDependantDetailLevel> T0115RcDependantDetailLevels { get; set; } = new List<T0115RcDependantDetailLevel>();

    public virtual ICollection<T0115RcLtaTravelDetailLevel> T0115RcLtaTravelDetailLevels { get; set; } = new List<T0115RcLtaTravelDetailLevel>();

    public virtual ICollection<T0115RcReimbursementDetailLevel> T0115RcReimbursementDetailLevels { get; set; } = new List<T0115RcReimbursementDetailLevel>();

    public virtual ICollection<T0115RecruitmentResponsibiltyLevel> T0115RecruitmentResponsibiltyLevels { get; set; } = new List<T0115RecruitmentResponsibiltyLevel>();

    public virtual ICollection<T0115RecruitmentSkillLevel> T0115RecruitmentSkillLevels { get; set; } = new List<T0115RecruitmentSkillLevel>();

    public virtual ICollection<T0115TravelApprovalAdvdetailLevel> T0115TravelApprovalAdvdetailLevels { get; set; } = new List<T0115TravelApprovalAdvdetailLevel>();

    public virtual ICollection<T0115TravelApprovalDetailLevel> T0115TravelApprovalDetailLevels { get; set; } = new List<T0115TravelApprovalDetailLevel>();

    public virtual ICollection<T0115TravelApprovalOtherDetailLevel> T0115TravelApprovalOtherDetailLevels { get; set; } = new List<T0115TravelApprovalOtherDetailLevel>();

    public virtual ICollection<T0115TravelLevelApproval> T0115TravelLevelApprovals { get; set; } = new List<T0115TravelLevelApproval>();

    public virtual ICollection<T0115TravelSettlementLevelApproval> T0115TravelSettlementLevelApprovals { get; set; } = new List<T0115TravelSettlementLevelApproval>();

    public virtual ICollection<T0115TravelSettlementLevelExpense> T0115TravelSettlementLevelExpenses { get; set; } = new List<T0115TravelSettlementLevelExpense>();

    public virtual ICollection<T0120ArApproval> T0120ArApprovals { get; set; } = new List<T0120ArApproval>();

    public virtual ICollection<T0120ClaimApproval> T0120ClaimApprovals { get; set; } = new List<T0120ClaimApproval>();

    public virtual ICollection<T0120CompOffApproval> T0120CompOffApprovals { get; set; } = new List<T0120CompOffApproval>();

    public virtual ICollection<T0120GradewiseAllowance> T0120GradewiseAllowances { get; set; } = new List<T0120GradewiseAllowance>();

    public virtual ICollection<T0120HrmsTrainingApproval> T0120HrmsTrainingApprovals { get; set; } = new List<T0120HrmsTrainingApproval>();

    public virtual ICollection<T0120HrmsTrainingAttachment> T0120HrmsTrainingAttachments { get; set; } = new List<T0120HrmsTrainingAttachment>();

    public virtual ICollection<T0120LeaveEncashApproval> T0120LeaveEncashApprovals { get; set; } = new List<T0120LeaveEncashApproval>();

    public virtual ICollection<T0120LoanApproval> T0120LoanApprovals { get; set; } = new List<T0120LoanApproval>();

    public virtual ICollection<T0120LtaMedicalApproval> T0120LtaMedicalApprovals { get; set; } = new List<T0120LtaMedicalApproval>();

    public virtual ICollection<T0120NightHaltApproval> T0120NightHaltApprovals { get; set; } = new List<T0120NightHaltApproval>();

    public virtual ICollection<T0120OpHolidayApproval> T0120OpHolidayApprovals { get; set; } = new List<T0120OpHolidayApproval>();

    public virtual ICollection<T0120TrainingApproval> T0120TrainingApprovals { get; set; } = new List<T0120TrainingApproval>();

    public virtual ICollection<T0120TravelApproval> T0120TravelApprovals { get; set; } = new List<T0120TravelApproval>();

    public virtual ICollection<T0120TsApproval> T0120TsApprovals { get; set; } = new List<T0120TsApproval>();

    public virtual ICollection<T0130ArApprovalDetail> T0130ArApprovalDetails { get; set; } = new List<T0130ArApprovalDetail>();

    public virtual ICollection<T0130AssetApprovalDet> T0130AssetApprovalDets { get; set; } = new List<T0130AssetApprovalDet>();

    public virtual ICollection<T0130ClaimApprovalDetail> T0130ClaimApprovalDetails { get; set; } = new List<T0130ClaimApprovalDetail>();

    public virtual ICollection<T0130HrmsTrainingAlert> T0130HrmsTrainingAlerts { get; set; } = new List<T0130HrmsTrainingAlert>();

    public virtual ICollection<T0130HrmsTrainingEmployeeDetail> T0130HrmsTrainingEmployeeDetails { get; set; } = new List<T0130HrmsTrainingEmployeeDetail>();

    public virtual ICollection<T0130HrmsTrainingFeedbackDetail> T0130HrmsTrainingFeedbackDetails { get; set; } = new List<T0130HrmsTrainingFeedbackDetail>();

    public virtual ICollection<T0130LtaForDependant> T0130LtaForDependants { get; set; } = new List<T0130LtaForDependant>();

    public virtual ICollection<T0130LtaJurneyDetail> T0130LtaJurneyDetails { get; set; } = new List<T0130LtaJurneyDetail>();

    public virtual ICollection<T0130TravelApprovalAdvdetail> T0130TravelApprovalAdvdetails { get; set; } = new List<T0130TravelApprovalAdvdetail>();

    public virtual ICollection<T0130TravelApprovalDetail> T0130TravelApprovalDetails { get; set; } = new List<T0130TravelApprovalDetail>();

    public virtual ICollection<T0130TravelHelpDesk> T0130TravelHelpDesks { get; set; } = new List<T0130TravelHelpDesk>();

    public virtual ICollection<T0130TsApprovalDetail> T0130TsApprovalDetails { get; set; } = new List<T0130TsApprovalDetail>();

    public virtual ICollection<T0135LeaveCancelation> T0135LeaveCancelations { get; set; } = new List<T0135LeaveCancelation>();

    public virtual ICollection<T0140AdvanceTransaction> T0140AdvanceTransactions { get; set; } = new List<T0140AdvanceTransaction>();

    public virtual ICollection<T0140AssetTransaction> T0140AssetTransactions { get; set; } = new List<T0140AssetTransaction>();

    public virtual ICollection<T0140BondTransaction> T0140BondTransactions { get; set; } = new List<T0140BondTransaction>();

    public virtual ICollection<T0140ClaimTransaction> T0140ClaimTransactions { get; set; } = new List<T0140ClaimTransaction>();

    public virtual ICollection<T0140HrmsTrainingFeedback> T0140HrmsTrainingFeedbacks { get; set; } = new List<T0140HrmsTrainingFeedback>();

    public virtual ICollection<T0140LateTransaction> T0140LateTransactions { get; set; } = new List<T0140LateTransaction>();

    public virtual ICollection<T0140LeaveTransaction> T0140LeaveTransactions { get; set; } = new List<T0140LeaveTransaction>();

    public virtual ICollection<T0140LoanTransaction> T0140LoanTransactions { get; set; } = new List<T0140LoanTransaction>();

    public virtual ICollection<T0140ReimClaimTransacation> T0140ReimClaimTransacations { get; set; } = new List<T0140ReimClaimTransacation>();

    public virtual ICollection<T0140TravelSettlementExpense> T0140TravelSettlementExpenses { get; set; } = new List<T0140TravelSettlementExpense>();

    public virtual ICollection<T0140TravelSettlementGroupEmp> T0140TravelSettlementGroupEmps { get; set; } = new List<T0140TravelSettlementGroupEmp>();

    public virtual ICollection<T0150AuditEmpInoutRecord> T0150AuditEmpInoutRecords { get; set; } = new List<T0150AuditEmpInoutRecord>();

    public virtual ICollection<T0150EmpCanteenPunch> T0150EmpCanteenPunches { get; set; } = new List<T0150EmpCanteenPunch>();

    public virtual ICollection<T0150EmpInoutRecord> T0150EmpInoutRecords { get; set; } = new List<T0150EmpInoutRecord>();

    public virtual ICollection<T0150EmpTrainingInoutRecord> T0150EmpTrainingInoutRecords { get; set; } = new List<T0150EmpTrainingInoutRecord>();

    public virtual ICollection<T0150EmpWorkDetail> T0150EmpWorkDetails { get; set; } = new List<T0150EmpWorkDetail>();

    public virtual ICollection<T0150HrmsTrainingQuestionnaire> T0150HrmsTrainingQuestionnaires { get; set; } = new List<T0150HrmsTrainingQuestionnaire>();

    public virtual ICollection<T0150TravelSettlementApprovalExpense> T0150TravelSettlementApprovalExpenses { get; set; } = new List<T0150TravelSettlementApprovalExpense>();

    public virtual ICollection<T0152HrmsTrainingQuestFinal> T0152HrmsTrainingQuestFinals { get; set; } = new List<T0152HrmsTrainingQuestFinal>();

    public virtual ICollection<T0160HrmsManagerFeedbackResponse> T0160HrmsManagerFeedbackResponses { get; set; } = new List<T0160HrmsManagerFeedbackResponse>();

    public virtual ICollection<T0160HrmsTrainingQuestionnaireResponse> T0160HrmsTrainingQuestionnaireResponses { get; set; } = new List<T0160HrmsTrainingQuestionnaireResponse>();

    public virtual ICollection<T0160LateApproval> T0160LateApprovals { get; set; } = new List<T0160LateApproval>();

    public virtual ICollection<T0160OtApproval> T0160OtApprovals { get; set; } = new List<T0160OtApproval>();

    public virtual ICollection<T0180Bonu> T0180Bonus { get; set; } = new List<T0180Bonu>();

    public virtual ICollection<T0190BonusDetail> T0190BonusDetails { get; set; } = new List<T0190BonusDetail>();

    public virtual ICollection<T0190EmpArrearDetail> T0190EmpArrearDetails { get; set; } = new List<T0190EmpArrearDetail>();

    public virtual ICollection<T0190MonthlyAdDetailImport> T0190MonthlyAdDetailImports { get; set; } = new List<T0190MonthlyAdDetailImport>();

    public virtual ICollection<T0190MonthlyPresentImport> T0190MonthlyPresentImports { get; set; } = new List<T0190MonthlyPresentImport>();

    public virtual ICollection<T0190ProductionBonusVariableImport> T0190ProductionBonusVariableImports { get; set; } = new List<T0190ProductionBonusVariableImport>();

    public virtual ICollection<T0190TaxPlanning> T0190TaxPlannings { get; set; } = new List<T0190TaxPlanning>();

    public virtual ICollection<T0200EmpExitApplication> T0200EmpExitApplications { get; set; } = new List<T0200EmpExitApplication>();

    public virtual ICollection<T0200ExitInterview> T0200ExitInterviews { get; set; } = new List<T0200ExitInterview>();

    public virtual ICollection<T0200MonthlySalary> T0200MonthlySalaries { get; set; } = new List<T0200MonthlySalary>();

    public virtual ICollection<T0200MonthlySalaryDaily> T0200MonthlySalaryDailies { get; set; } = new List<T0200MonthlySalaryDaily>();

    public virtual ICollection<T0200MonthlySalaryLeave> T0200MonthlySalaryLeaves { get; set; } = new List<T0200MonthlySalaryLeave>();

    public virtual ICollection<T0200QuestionMaster> T0200QuestionMasters { get; set; } = new List<T0200QuestionMaster>();

    public virtual ICollection<T0201MonthlySalarySett> T0201MonthlySalarySetts { get; set; } = new List<T0201MonthlySalarySett>();

    public virtual ICollection<T0210LtaMedicalPayment> T0210LtaMedicalPayments { get; set; } = new List<T0210LtaMedicalPayment>();

    public virtual ICollection<T0210MonthlyAdDetailDaily> T0210MonthlyAdDetailDailies { get; set; } = new List<T0210MonthlyAdDetailDaily>();

    public virtual ICollection<T0210MonthlyAdDetailImport> T0210MonthlyAdDetailImports { get; set; } = new List<T0210MonthlyAdDetailImport>();

    public virtual ICollection<T0210MonthlyAdDetail> T0210MonthlyAdDetails { get; set; } = new List<T0210MonthlyAdDetail>();

    public virtual ICollection<T0210MonthlyBondPayment> T0210MonthlyBondPayments { get; set; } = new List<T0210MonthlyBondPayment>();

    public virtual ICollection<T0210MonthlyLeaveDetail> T0210MonthlyLeaveDetails { get; set; } = new List<T0210MonthlyLeaveDetail>();

    public virtual ICollection<T0210MonthlyLoanPayment> T0210MonthlyLoanPayments { get; set; } = new List<T0210MonthlyLoanPayment>();

    public virtual ICollection<T0210MonthlyPresentCalculation> T0210MonthlyPresentCalculations { get; set; } = new List<T0210MonthlyPresentCalculation>();

    public virtual ICollection<T0210MonthlyReimDetail> T0210MonthlyReimDetails { get; set; } = new List<T0210MonthlyReimDetail>();

    public virtual ICollection<T0210PayslipDatum> T0210PayslipData { get; set; } = new List<T0210PayslipDatum>();

    public virtual ICollection<T0210PayslipDataDaily> T0210PayslipDataDailies { get; set; } = new List<T0210PayslipDataDaily>();

    public virtual ICollection<T0220EsicChallanSett> T0220EsicChallanSetts { get; set; } = new List<T0220EsicChallanSett>();

    public virtual ICollection<T0220EsicChallan> T0220EsicChallans { get; set; } = new List<T0220EsicChallan>();

    public virtual ICollection<T0220PfChallanSett> T0220PfChallanSetts { get; set; } = new List<T0220PfChallanSett>();

    public virtual ICollection<T0220PfChallan> T0220PfChallans { get; set; } = new List<T0220PfChallan>();

    public virtual ICollection<T0220PtChallan> T0220PtChallans { get; set; } = new List<T0220PtChallan>();

    public virtual ICollection<T0220TdsChallan> T0220TdsChallans { get; set; } = new List<T0220TdsChallan>();

    public virtual ICollection<T0230MonthlyClaimPaymentDetail> T0230MonthlyClaimPaymentDetails { get; set; } = new List<T0230MonthlyClaimPaymentDetail>();

    public virtual ICollection<T0230PfChallanDetailSett> T0230PfChallanDetailSetts { get; set; } = new List<T0230PfChallanDetailSett>();

    public virtual ICollection<T0230PfChallanDetail> T0230PfChallanDetails { get; set; } = new List<T0230PfChallanDetail>();

    public virtual ICollection<T0240LtaMedicalTransaction> T0240LtaMedicalTransactions { get; set; } = new List<T0240LtaMedicalTransaction>();

    public virtual ICollection<T0250ChangePasswordHistory> T0250ChangePasswordHistories { get; set; } = new List<T0250ChangePasswordHistory>();

    public virtual ICollection<T0250ItPaid> T0250ItPaids { get; set; } = new List<T0250ItPaid>();

    public virtual ICollection<T0251ItPaidDetail> T0251ItPaidDetails { get; set; } = new List<T0251ItPaidDetail>();

    public virtual ICollection<T0302PaymentProcessTravelDetail> T0302PaymentProcessTravelDetails { get; set; } = new List<T0302PaymentProcessTravelDetail>();

    public virtual ICollection<T9999SalaryExportCostDetail> T9999SalaryExportCostDetails { get; set; } = new List<T9999SalaryExportCostDetail>();

    public virtual ICollection<T9999SalaryExportDetail> T9999SalaryExportDetails { get; set; } = new List<T9999SalaryExportDetail>();

    public virtual ICollection<T9999SalaryExport> T9999SalaryExports { get; set; } = new List<T9999SalaryExport>();

    public virtual ICollection<Table2> Table2s { get; set; } = new List<Table2>();

    public virtual ICollection<TblEmailDetail> TblEmailDetails { get; set; } = new List<TblEmailDetail>();
}
