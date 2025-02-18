using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0080EmpMaster
{
    public decimal EmpId { get; set; }

    public decimal CmpId { get; set; }

    public decimal BranchId { get; set; }

    public decimal? CatId { get; set; }

    public decimal GrdId { get; set; }

    public decimal? DeptId { get; set; }

    public decimal? DesigId { get; set; }

    public decimal? TypeId { get; set; }

    public decimal ShiftId { get; set; }

    public decimal? BankId { get; set; }

    public decimal EmpCode { get; set; }

    public string? Initial { get; set; }

    public string EmpFirstName { get; set; } = null!;

    public string EmpSecondName { get; set; } = null!;

    public string EmpLastName { get; set; } = null!;

    public decimal? CurrId { get; set; }

    public DateTime DateOfJoin { get; set; }

    public string? SsnNo { get; set; }

    public string? SinNo { get; set; }

    public string? DrLicNo { get; set; }

    public string? PanNo { get; set; }

    public DateTime? DateOfBirth { get; set; }

    public string? MaritalStatus { get; set; }

    public string? Gender { get; set; }

    public DateTime? DrLicExDate { get; set; }

    public string? Nationality { get; set; }

    public decimal? LocId { get; set; }

    public string? Street1 { get; set; }

    public string? City { get; set; }

    public string? State { get; set; }

    public string? ZipCode { get; set; }

    public string? HomeTelNo { get; set; }

    public string? MobileNo { get; set; }

    public string? WorkTelNo { get; set; }

    public string? WorkEmail { get; set; }

    public string? OtherEmail { get; set; }

    public decimal? BasicSalary { get; set; }

    public string? ImageName { get; set; }

    public string? EmpFullName { get; set; }

    public string? EmpLeft { get; set; }

    public DateTime? EmpLeftDate { get; set; }

    public decimal? IncrementId { get; set; }

    public string? PresentStreet { get; set; }

    public string? PresentCity { get; set; }

    public string? PresentState { get; set; }

    public string? PresentPostBox { get; set; }

    public decimal? EmpSuperior { get; set; }

    public decimal? EnrollNo { get; set; }

    public string? BloodGroup { get; set; }

    public string? TallyLedName { get; set; }

    public string? Religion { get; set; }

    public string? Height { get; set; }

    public string? EmpMarkOfIdentification { get; set; }

    public string? Despencery { get; set; }

    public string? DoctorName { get; set; }

    public string? DespenceryAddress { get; set; }

    public string? InsuranceNo { get; set; }

    public byte? IsGrApp { get; set; }

    public byte? IsYearlyBonus { get; set; }

    public decimal? YearlyLeaveDays { get; set; }

    public decimal? YearlyLeaveAmount { get; set; }

    public decimal? YearlyBonusPer { get; set; }

    public decimal? YearlyBonusAmount { get; set; }

    public DateTime? EmpConfirmDate { get; set; }

    public byte? IsEmpFnf { get; set; }

    public byte? IsOnProbation { get; set; }

    public decimal? TallyLedId { get; set; }

    public decimal? LoginId { get; set; }

    public DateTime? SystemDate { get; set; }

    public decimal? Probation { get; set; }

    public decimal? WorkerAdultNo { get; set; }

    public string? FatherName { get; set; }

    public string? BankBsr { get; set; }

    public string? ProductName { get; set; }

    public string? OldRefNo { get; set; }

    public int? ChgPwd { get; set; }

    public string? AlphaCode { get; set; }

    public string? AlphaEmpCode { get; set; }

    public string? IfscCode { get; set; }

    public byte? LeaveInProbation { get; set; }

    public byte IsLwf { get; set; }

    public string? DbrdCode { get; set; }

    public string? DealerCode { get; set; }

    public string? CcenterRemark { get; set; }

    public decimal EmpPfOpening { get; set; }

    public string? EmpCategory { get; set; }

    public string? EmpUidno { get; set; }

    public string? EmpCast { get; set; }

    public string? EmpAnnivarsaryDate { get; set; }

    public decimal? ExtraAbDeduction { get; set; }

    public string CompOffMinHrs { get; set; } = null!;

    public string? MotherName { get; set; }

    public decimal MinWages { get; set; }

    public DateTime? EmpOfferDate { get; set; }

    public decimal? SegmentId { get; set; }

    public decimal? VerticalId { get; set; }

    public decimal? SubVerticalId { get; set; }

    public DateTime? GroupJoiningDate { get; set; }

    public decimal? SubBranchId { get; set; }

    public decimal? BankIdTwo { get; set; }

    public string? IfscCodeTwo { get; set; }

    public string? CodeDateFormat { get; set; }

    public string? CodeDate { get; set; }

    public string? EmpNameAliasPrimaryBank { get; set; }

    public string? EmpNameAliasSecondaryBank { get; set; }

    public string? EmpNameAliasPf { get; set; }

    public string? EmpNameAliasPt { get; set; }

    public string? EmpNameAliasTax { get; set; }

    public string? EmpNameAliasEsic { get; set; }

    public string? EmpNameAliasSalary { get; set; }

    public decimal EmpNoticePeriod { get; set; }

    public DateTime? SystemDateJoinLeft { get; set; }

    public string? EmpCanteenCode { get; set; }

    public string? EmpDressCode { get; set; }

    public string? EmpShirtSize { get; set; }

    public string? EmpPentSize { get; set; }

    public string? EmpShoeSize { get; set; }

    public decimal ThanaId { get; set; }

    public string? Tehsil { get; set; }

    public string? District { get; set; }

    public decimal ThanaIdWok { get; set; }

    public string? TehsilWok { get; set; }

    public string? DistrictWok { get; set; }

    public int? SkillTypeId { get; set; }

    public string? AboutMe { get; set; }

    public string? UanNo { get; set; }

    public decimal CompOffWoAppDays { get; set; }

    public decimal CompOffWoAvailDays { get; set; }

    public decimal CompOffWdAppDays { get; set; }

    public decimal CompOffWdAvailDays { get; set; }

    public decimal CompOffHoAppDays { get; set; }

    public decimal CompOffHoAvailDays { get; set; }

    public DateTime? DateOfRetirement { get; set; }

    public decimal SalaryDependsOnProduction { get; set; }

    public string? RationCardType { get; set; }

    public string? RationCardNo { get; set; }

    public string? VehicleNo { get; set; }

    public decimal IsOnTraining { get; set; }

    public decimal? TrainingMonth { get; set; }

    public string? AadharCardNo { get; set; }

    public byte IsForMobileAccess { get; set; }

    public DateTime? ActualDateOfBirth { get; set; }

    public byte IsPfTrust { get; set; }

    public string? PfTrustNo { get; set; }

    public string? ExtensionNo { get; set; }

    public decimal ManagerProbation { get; set; }

    public DateTime? PfStartDate { get; set; }

    public string? LinkedInId { get; set; }

    public string? TwitterId { get; set; }

    public decimal IsOnTraning { get; set; }

    public decimal Traning { get; set; }

    public string? SignatureImageName { get; set; }

    public decimal LeaveEncashWorkingDays { get; set; }

    public decimal RejoinEmpId { get; set; }

    public byte IsCameraEnable { get; set; }

    public byte IsGeofenceEnable { get; set; }

    public byte IsProbationMonthDays { get; set; }

    public byte IsTraineeMonthDays { get; set; }

    public string? InductionTraining { get; set; }

    public decimal? HolidayCompOffAvailAfterDays { get; set; }

    public decimal? WeekOffCompOffAvailAfterDays { get; set; }

    public decimal? WeekdayCompOffAvailAfterDays { get; set; }

    public byte IsMobileWorkplanEnable { get; set; }

    public byte IsMobileStockEnable { get; set; }

    public byte IsVba { get; set; }

    public byte? IsPieceTransSalary { get; set; }

    public decimal? BandId { get; set; }

    public bool? IsPradhanMantri { get; set; }

    public bool? Is1timePfMember { get; set; }

    public string? EmpCastJoin { get; set; }

    public string? EmpFavSportId { get; set; }

    public string? EmpFavSportName { get; set; }

    public string? EmpHobbyId { get; set; }

    public string? EmpHobbyName { get; set; }

    public string? EmpFavFood { get; set; }

    public string? EmpFavRestro { get; set; }

    public string? EmpFavTrvDestination { get; set; }

    public string? EmpFavFestival { get; set; }

    public string? EmpFavSportPerson { get; set; }

    public string? EmpFavSinger { get; set; }

    public byte IsGuestPrivilege { get; set; }

    public virtual T0040BankMaster? Bank { get; set; }

    public virtual T0030BranchMaster Branch { get; set; } = null!;

    public virtual T0030CategoryMaster? Cat { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0040DepartmentMaster? Dept { get; set; }

    public virtual T0040DesignationMaster? Desig { get; set; }

    public virtual ICollection<EmpForFnfAllowance> EmpForFnfAllowances { get; set; } = new List<EmpForFnfAllowance>();

    public virtual T0040GradeMaster Grd { get; set; } = null!;

    public virtual T0095Increment? Increment { get; set; }

    public virtual T0001LocationMaster? Loc { get; set; }

    public virtual T0011Login? Login { get; set; }

    public virtual ICollection<MonthlyEmpBankPayment> MonthlyEmpBankPayments { get; set; } = new List<MonthlyEmpBankPayment>();

    public virtual T0040ShiftMaster Shift { get; set; } = null!;

    public virtual ICollection<T0040EmpKpiMaster> T0040EmpKpiMasters { get; set; } = new List<T0040EmpKpiMaster>();

    public virtual ICollection<T0040EmployeeTransportRegistration> T0040EmployeeTransportRegistrations { get; set; } = new List<T0040EmployeeTransportRegistration>();

    public virtual ICollection<T0050EmpSubProductDetail> T0050EmpSubProductDetails { get; set; } = new List<T0050EmpSubProductDetail>();

    public virtual ICollection<T0050HrmsEmpOaFeedback> T0050HrmsEmpOaFeedbacks { get; set; } = new List<T0050HrmsEmpOaFeedback>();

    public virtual ICollection<T0050HrmsRecruitmentRequest> T0050HrmsRecruitmentRequests { get; set; } = new List<T0050HrmsRecruitmentRequest>();

    public virtual ICollection<T0050TaskDetail> T0050TaskDetails { get; set; } = new List<T0050TaskDetail>();

    public virtual ICollection<T0052HrmsAppTrainDetail> T0052HrmsAppTrainDetails { get; set; } = new List<T0052HrmsAppTrainDetail>();

    public virtual ICollection<T0052HrmsAppTrainingDetail> T0052HrmsAppTrainingDetails { get; set; } = new List<T0052HrmsAppTrainingDetail>();

    public virtual ICollection<T0052HrmsAppTraining> T0052HrmsAppTrainings { get; set; } = new List<T0052HrmsAppTraining>();

    public virtual ICollection<T0052HrmsAttributeFeedback> T0052HrmsAttributeFeedbacks { get; set; } = new List<T0052HrmsAttributeFeedback>();

    public virtual ICollection<T0052HrmsKpa> T0052HrmsKpas { get; set; } = new List<T0052HrmsKpa>();

    public virtual ICollection<T0052HrmsPerformanceAnswer> T0052HrmsPerformanceAnswers { get; set; } = new List<T0052HrmsPerformanceAnswer>();

    public virtual ICollection<T0052HrmsPostedRecruitment> T0052HrmsPostedRecruitments { get; set; } = new List<T0052HrmsPostedRecruitment>();

    public virtual ICollection<T0055HrmsEmpSkillDetail> T0055HrmsEmpSkillDetailEmps { get; set; } = new List<T0055HrmsEmpSkillDetail>();

    public virtual ICollection<T0055HrmsEmpSkillDetail> T0055HrmsEmpSkillDetailSEmps { get; set; } = new List<T0055HrmsEmpSkillDetail>();

    public virtual ICollection<T0055HrmsInitiateKpasetting> T0055HrmsInitiateKpasettingEmps { get; set; } = new List<T0055HrmsInitiateKpasetting>();

    public virtual ICollection<T0055HrmsInitiateKpasetting> T0055HrmsInitiateKpasettingGhs { get; set; } = new List<T0055HrmsInitiateKpasetting>();

    public virtual ICollection<T0055HrmsInitiateKpasetting> T0055HrmsInitiateKpasettingHods { get; set; } = new List<T0055HrmsInitiateKpasetting>();

    public virtual ICollection<T0055HrmsInterviewScheduleHistory> T0055HrmsInterviewScheduleHistories { get; set; } = new List<T0055HrmsInterviewScheduleHistory>();

    public virtual ICollection<T0060AppraisalEmpWeightage> T0060AppraisalEmpWeightages { get; set; } = new List<T0060AppraisalEmpWeightage>();

    public virtual ICollection<T0060AppraisalEmployeeKpa> T0060AppraisalEmployeeKpas { get; set; } = new List<T0060AppraisalEmployeeKpa>();

    public virtual ICollection<T0060ExtraIncrementUtility> T0060ExtraIncrementUtilities { get; set; } = new List<T0060ExtraIncrementUtility>();

    public virtual ICollection<T0060SurveyEmployeeResponse> T0060SurveyEmployeeResponses { get; set; } = new List<T0060SurveyEmployeeResponse>();

    public virtual ICollection<T0080EmpKpi> T0080EmpKpis { get; set; } = new List<T0080EmpKpi>();

    public virtual ICollection<T0080KpiDevelopmentPlan> T0080KpiDevelopmentPlans { get; set; } = new List<T0080KpiDevelopmentPlan>();

    public virtual ICollection<T0080KpipmsEval> T0080KpipmsEvals { get; set; } = new List<T0080KpipmsEval>();

    public virtual ICollection<T0080Kpirating> T0080Kpiratings { get; set; } = new List<T0080Kpirating>();

    public virtual ICollection<T0080SubKpiMaster> T0080SubKpiMasters { get; set; } = new List<T0080SubKpiMaster>();

    public virtual ICollection<T0090AdvancePaymentApproval> T0090AdvancePaymentApprovals { get; set; } = new List<T0090AdvancePaymentApproval>();

    public virtual ICollection<T0090BalanceScoreCardSetting> T0090BalanceScoreCardSettings { get; set; } = new List<T0090BalanceScoreCardSetting>();

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

    public virtual ICollection<T0090EmpReportingDetail> T0090EmpReportingDetailEmps { get; set; } = new List<T0090EmpReportingDetail>();

    public virtual ICollection<T0090EmpReportingDetail> T0090EmpReportingDetailREmps { get; set; } = new List<T0090EmpReportingDetail>();

    public virtual ICollection<T0090EmpSkillDetail> T0090EmpSkillDetails { get; set; } = new List<T0090EmpSkillDetail>();

    public virtual ICollection<T0090EmployeeGoalSetting> T0090EmployeeGoalSettings { get; set; } = new List<T0090EmployeeGoalSetting>();

    public virtual ICollection<T0090HrmsAppraisalInitiationDetail> T0090HrmsAppraisalInitiationDetails { get; set; } = new List<T0090HrmsAppraisalInitiationDetail>();

    public virtual ICollection<T0090HrmsEmpSkillSetting> T0090HrmsEmpSkillSettings { get; set; } = new List<T0090HrmsEmpSkillSetting>();

    public virtual ICollection<T0090HrmsFinalScore> T0090HrmsFinalScores { get; set; } = new List<T0090HrmsFinalScore>();

    public virtual ICollection<T0090KpipmsEvalApproval> T0090KpipmsEvalApprovals { get; set; } = new List<T0090KpipmsEvalApproval>();

    public virtual ICollection<T0090KpipmsObjective> T0090KpipmsObjectives { get; set; } = new List<T0090KpipmsObjective>();

    public virtual ICollection<T0090PerformanceImprovementPlan> T0090PerformanceImprovementPlans { get; set; } = new List<T0090PerformanceImprovementPlan>();

    public virtual ICollection<T0090UniformRequisitionApplication> T0090UniformRequisitionApplications { get; set; } = new List<T0090UniformRequisitionApplication>();

    public virtual ICollection<T0095BalanceScoreCardEvaluation> T0095BalanceScoreCardEvaluations { get; set; } = new List<T0095BalanceScoreCardEvaluation>();

    public virtual ICollection<T0095BalanceScoreCardSettingDetail> T0095BalanceScoreCardSettingDetails { get; set; } = new List<T0095BalanceScoreCardSettingDetail>();

    public virtual ICollection<T0095DevelopmentPlanningTemplateDetail> T0095DevelopmentPlanningTemplateDetails { get; set; } = new List<T0095DevelopmentPlanningTemplateDetail>();

    public virtual ICollection<T0095EmpProbationMaster> T0095EmpProbationMasters { get; set; } = new List<T0095EmpProbationMaster>();

    public virtual ICollection<T0095EmpSchema> T0095EmpSchemas { get; set; } = new List<T0095EmpSchema>();

    public virtual ICollection<T0095EmpScheme> T0095EmpSchemes { get; set; } = new List<T0095EmpScheme>();

    public virtual ICollection<T0095EmployeeGoalSettingDetail> T0095EmployeeGoalSettingDetails { get; set; } = new List<T0095EmployeeGoalSettingDetail>();

    public virtual ICollection<T0095EmployeeGoalSettingEvaluation> T0095EmployeeGoalSettingEvaluations { get; set; } = new List<T0095EmployeeGoalSettingEvaluation>();

    public virtual ICollection<T0095Increment> T0095Increments { get; set; } = new List<T0095Increment>();

    public virtual ICollection<T0095ItEmpTaxRegime> T0095ItEmpTaxRegimes { get; set; } = new List<T0095ItEmpTaxRegime>();

    public virtual ICollection<T0095LeaveOpening> T0095LeaveOpenings { get; set; } = new List<T0095LeaveOpening>();

    public virtual ICollection<T0095PerformanceImprovementPlanDetail> T0095PerformanceImprovementPlanDetails { get; set; } = new List<T0095PerformanceImprovementPlanDetail>();

    public virtual ICollection<T0095ReimOpening> T0095ReimOpenings { get; set; } = new List<T0095ReimOpening>();

    public virtual ICollection<T0095UniformRequisitionApplicationDetail> T0095UniformRequisitionApplicationDetails { get; set; } = new List<T0095UniformRequisitionApplicationDetail>();

    public virtual ICollection<T0100AdvancePayment> T0100AdvancePayments { get; set; } = new List<T0100AdvancePayment>();

    public virtual ICollection<T0100AnualBonu> T0100AnualBonus { get; set; } = new List<T0100AnualBonu>();

    public virtual ICollection<T0100ArApplication> T0100ArApplications { get; set; } = new List<T0100ArApplication>();

    public virtual ICollection<T0100BalanceScoreCardEvaluationDetail> T0100BalanceScoreCardEvaluationDetails { get; set; } = new List<T0100BalanceScoreCardEvaluationDetail>();

    public virtual ICollection<T0100ClaimApplication> T0100ClaimApplicationEmps { get; set; } = new List<T0100ClaimApplication>();

    public virtual ICollection<T0100ClaimApplication> T0100ClaimApplicationSEmps { get; set; } = new List<T0100ClaimApplication>();

    public virtual ICollection<T0100CompOffApplication> T0100CompOffApplicationEmps { get; set; } = new List<T0100CompOffApplication>();

    public virtual ICollection<T0100CompOffApplication> T0100CompOffApplicationSEmps { get; set; } = new List<T0100CompOffApplication>();

    public virtual ICollection<T0100EmpEarnDeduction> T0100EmpEarnDeductions { get; set; } = new List<T0100EmpEarnDeduction>();

    public virtual ICollection<T0100EmpGradeDetail> T0100EmpGradeDetails { get; set; } = new List<T0100EmpGradeDetail>();

    public virtual ICollection<T0100EmpKpiMasterLevel> T0100EmpKpiMasterLevels { get; set; } = new List<T0100EmpKpiMasterLevel>();

    public virtual ICollection<T0100EmpLateDetail> T0100EmpLateDetails { get; set; } = new List<T0100EmpLateDetail>();

    public virtual ICollection<T0100EmpLtaMedicalDetail> T0100EmpLtaMedicalDetails { get; set; } = new List<T0100EmpLtaMedicalDetail>();

    public virtual ICollection<T0100EmpPerformanceDetail> T0100EmpPerformanceDetails { get; set; } = new List<T0100EmpPerformanceDetail>();

    public virtual ICollection<T0100EmpProbationAttributeDetail> T0100EmpProbationAttributeDetails { get; set; } = new List<T0100EmpProbationAttributeDetail>();

    public virtual ICollection<T0100EmpProbationSkillDetail> T0100EmpProbationSkillDetails { get; set; } = new List<T0100EmpProbationSkillDetail>();

    public virtual ICollection<T0100EmpShiftDetail> T0100EmpShiftDetails { get; set; } = new List<T0100EmpShiftDetail>();

    public virtual ICollection<T0100EmployeeGoalSettingEvaluationDetail> T0100EmployeeGoalSettingEvaluationDetails { get; set; } = new List<T0100EmployeeGoalSettingEvaluationDetail>();

    public virtual ICollection<T0100EmployeeGoalSupEval> T0100EmployeeGoalSupEvals { get; set; } = new List<T0100EmployeeGoalSupEval>();

    public virtual ICollection<T0100GatePassApplication> T0100GatePassApplications { get; set; } = new List<T0100GatePassApplication>();

    public virtual ICollection<T0100Gratuity> T0100Gratuities { get; set; } = new List<T0100Gratuity>();

    public virtual ICollection<T0100HrmsTrainingApplication> T0100HrmsTrainingApplications { get; set; } = new List<T0100HrmsTrainingApplication>();

    public virtual ICollection<T0100ItDeclaration> T0100ItDeclarations { get; set; } = new List<T0100ItDeclaration>();

    public virtual ICollection<T0100LeaveApplication> T0100LeaveApplicationEmps { get; set; } = new List<T0100LeaveApplication>();

    public virtual ICollection<T0100LeaveApplication> T0100LeaveApplicationSEmps { get; set; } = new List<T0100LeaveApplication>();

    public virtual ICollection<T0100LeaveCfDetail> T0100LeaveCfDetails { get; set; } = new List<T0100LeaveCfDetail>();

    public virtual ICollection<T0100LeaveEncashApplication> T0100LeaveEncashApplications { get; set; } = new List<T0100LeaveEncashApplication>();

    public virtual ICollection<T0100LeftEmp> T0100LeftEmps { get; set; } = new List<T0100LeftEmp>();

    public virtual ICollection<T0100LoanApplication> T0100LoanApplications { get; set; } = new List<T0100LoanApplication>();

    public virtual ICollection<T0100NightHaltApplication> T0100NightHaltApplications { get; set; } = new List<T0100NightHaltApplication>();

    public virtual ICollection<T0100OpHolidayApplication> T0100OpHolidayApplications { get; set; } = new List<T0100OpHolidayApplication>();

    public virtual ICollection<T0100ProjectAllocation> T0100ProjectAllocations { get; set; } = new List<T0100ProjectAllocation>();

    public virtual ICollection<T0100RcApplication> T0100RcApplications { get; set; } = new List<T0100RcApplication>();

    public virtual ICollection<T0100RimbursementDetail> T0100RimbursementDetails { get; set; } = new List<T0100RimbursementDetail>();

    public virtual ICollection<T0100TravelApplication> T0100TravelApplicationEmps { get; set; } = new List<T0100TravelApplication>();

    public virtual ICollection<T0100TravelApplication> T0100TravelApplicationSEmps { get; set; } = new List<T0100TravelApplication>();

    public virtual ICollection<T0100TsApplication> T0100TsApplications { get; set; } = new List<T0100TsApplication>();

    public virtual ICollection<T0100UniformRequisitionApproval> T0100UniformRequisitionApprovalApprovedByEmps { get; set; } = new List<T0100UniformRequisitionApproval>();

    public virtual ICollection<T0100UniformRequisitionApproval> T0100UniformRequisitionApprovalEmps { get; set; } = new List<T0100UniformRequisitionApproval>();

    public virtual ICollection<T0100VehicleApplication> T0100VehicleApplications { get; set; } = new List<T0100VehicleApplication>();

    public virtual ICollection<T0100WarningDetail> T0100WarningDetails { get; set; } = new List<T0100WarningDetail>();

    public virtual ICollection<T0100WeekoffAdj> T0100WeekoffAdjs { get; set; } = new List<T0100WeekoffAdj>();

    public virtual ICollection<T0110AssetInstallationDetail> T0110AssetInstallationDetails { get; set; } = new List<T0110AssetInstallationDetail>();

    public virtual ICollection<T0110BalanceScoreCardEvaluationApproval> T0110BalanceScoreCardEvaluationApprovals { get; set; } = new List<T0110BalanceScoreCardEvaluationApproval>();

    public virtual ICollection<T0110BalanceScoreCardSettingApproval> T0110BalanceScoreCardSettingApprovals { get; set; } = new List<T0110BalanceScoreCardSettingApproval>();

    public virtual ICollection<T0110EmpEarnDeductionRevised> T0110EmpEarnDeductionReviseds { get; set; } = new List<T0110EmpEarnDeductionRevised>();

    public virtual ICollection<T0110EmpLeftJoinTran> T0110EmpLeftJoinTrans { get; set; } = new List<T0110EmpLeftJoinTran>();

    public virtual ICollection<T0110EmpNextIncrementDetail> T0110EmpNextIncrementDetails { get; set; } = new List<T0110EmpNextIncrementDetail>();

    public virtual ICollection<T0110EmployeeGoalSettingApproval> T0110EmployeeGoalSettingApprovals { get; set; } = new List<T0110EmployeeGoalSettingApproval>();

    public virtual ICollection<T0110EmployeeGoalSettingEvaluationApproval> T0110EmployeeGoalSettingEvaluationApprovals { get; set; } = new List<T0110EmployeeGoalSettingEvaluationApproval>();

    public virtual ICollection<T0110RcLtaTravelDetail> T0110RcLtaTravelDetails { get; set; } = new List<T0110RcLtaTravelDetail>();

    public virtual ICollection<T0110RcReimbursementDetail> T0110RcReimbursementDetails { get; set; } = new List<T0110RcReimbursementDetail>();

    public virtual ICollection<T0110TrainingApplicationDetail> T0110TrainingApplicationDetails { get; set; } = new List<T0110TrainingApplicationDetail>();

    public virtual ICollection<T0110TrainingInductionDetail> T0110TrainingInductionDetails { get; set; } = new List<T0110TrainingInductionDetail>();

    public virtual ICollection<T0110TravelApplicationDetail> T0110TravelApplicationDetails { get; set; } = new List<T0110TravelApplicationDetail>();

    public virtual ICollection<T0110UniformDispatchDetail> T0110UniformDispatchDetailDispatchByEmps { get; set; } = new List<T0110UniformDispatchDetail>();

    public virtual ICollection<T0110UniformDispatchDetail> T0110UniformDispatchDetailEmps { get; set; } = new List<T0110UniformDispatchDetail>();

    public virtual ICollection<T0110VehicleRegistrationDetail> T0110VehicleRegistrationDetails { get; set; } = new List<T0110VehicleRegistrationDetail>();

    public virtual ICollection<T0115AttendanceReguLevelApproval> T0115AttendanceReguLevelApprovals { get; set; } = new List<T0115AttendanceReguLevelApproval>();

    public virtual ICollection<T0115BalanceScoreCardEvaluationDetailsLevel> T0115BalanceScoreCardEvaluationDetailsLevels { get; set; } = new List<T0115BalanceScoreCardEvaluationDetailsLevel>();

    public virtual ICollection<T0115BalanceScoreCardSettingDetailsLevel> T0115BalanceScoreCardSettingDetailsLevels { get; set; } = new List<T0115BalanceScoreCardSettingDetailsLevel>();

    public virtual ICollection<T0115ClaimLevelApprovalDetail> T0115ClaimLevelApprovalDetails { get; set; } = new List<T0115ClaimLevelApprovalDetail>();

    public virtual ICollection<T0115ClaimLevelApproval> T0115ClaimLevelApprovals { get; set; } = new List<T0115ClaimLevelApproval>();

    public virtual ICollection<T0115EmployeeGoalSettingDetailsLevel> T0115EmployeeGoalSettingDetailsLevels { get; set; } = new List<T0115EmployeeGoalSettingDetailsLevel>();

    public virtual ICollection<T0115EmployeeGoalSettingEvaluationDetailsLevel> T0115EmployeeGoalSettingEvaluationDetailsLevels { get; set; } = new List<T0115EmployeeGoalSettingEvaluationDetailsLevel>();

    public virtual ICollection<T0115EmployeeGoalSupEvalLevel> T0115EmployeeGoalSupEvalLevels { get; set; } = new List<T0115EmployeeGoalSupEvalLevel>();

    public virtual ICollection<T0115FileLevelApproval> T0115FileLevelApprovals { get; set; } = new List<T0115FileLevelApproval>();

    public virtual ICollection<T0115LeaveLevelApproval> T0115LeaveLevelApprovals { get; set; } = new List<T0115LeaveLevelApproval>();

    public virtual ICollection<T0115LoanLevelApproval> T0115LoanLevelApprovals { get; set; } = new List<T0115LoanLevelApproval>();

    public virtual ICollection<T0115TravelApprovalDetailLevel> T0115TravelApprovalDetailLevels { get; set; } = new List<T0115TravelApprovalDetailLevel>();

    public virtual ICollection<T0115TravelLevelApproval> T0115TravelLevelApprovals { get; set; } = new List<T0115TravelLevelApproval>();

    public virtual ICollection<T0115TravelSettlementLevelApproval> T0115TravelSettlementLevelApprovals { get; set; } = new List<T0115TravelSettlementLevelApproval>();

    public virtual ICollection<T0115TravelSettlementLevelExpense> T0115TravelSettlementLevelExpenses { get; set; } = new List<T0115TravelSettlementLevelExpense>();

    public virtual ICollection<T0120ArApproval> T0120ArApprovals { get; set; } = new List<T0120ArApproval>();

    public virtual ICollection<T0120ClaimApproval> T0120ClaimApprovals { get; set; } = new List<T0120ClaimApproval>();

    public virtual ICollection<T0120CompOffApproval> T0120CompOffApprovalEmps { get; set; } = new List<T0120CompOffApproval>();

    public virtual ICollection<T0120CompOffApproval> T0120CompOffApprovalSEmps { get; set; } = new List<T0120CompOffApproval>();

    public virtual ICollection<T0120LeaveApproval> T0120LeaveApprovalEmps { get; set; } = new List<T0120LeaveApproval>();

    public virtual ICollection<T0120LeaveApproval> T0120LeaveApprovalSEmps { get; set; } = new List<T0120LeaveApproval>();

    public virtual ICollection<T0120LeaveEncashApproval> T0120LeaveEncashApprovals { get; set; } = new List<T0120LeaveEncashApproval>();

    public virtual ICollection<T0120LoanApproval> T0120LoanApprovals { get; set; } = new List<T0120LoanApproval>();

    public virtual ICollection<T0120LtaMedicalApproval> T0120LtaMedicalApprovals { get; set; } = new List<T0120LtaMedicalApproval>();

    public virtual ICollection<T0120NightHaltApproval> T0120NightHaltApprovals { get; set; } = new List<T0120NightHaltApproval>();

    public virtual ICollection<T0120OpHolidayApproval> T0120OpHolidayApprovalEmps { get; set; } = new List<T0120OpHolidayApproval>();

    public virtual ICollection<T0120OpHolidayApproval> T0120OpHolidayApprovalSEmps { get; set; } = new List<T0120OpHolidayApproval>();

    public virtual ICollection<T0120TravelApproval> T0120TravelApprovalEmps { get; set; } = new List<T0120TravelApproval>();

    public virtual ICollection<T0120TravelApproval> T0120TravelApprovalSEmps { get; set; } = new List<T0120TravelApproval>();

    public virtual ICollection<T0120TsApproval> T0120TsApprovals { get; set; } = new List<T0120TsApproval>();

    public virtual ICollection<T0130ClaimApprovalDetail> T0130ClaimApprovalDetails { get; set; } = new List<T0130ClaimApprovalDetail>();

    public virtual ICollection<T0130HrmsTrainingAlert> T0130HrmsTrainingAlerts { get; set; } = new List<T0130HrmsTrainingAlert>();

    public virtual ICollection<T0130HrmsTrainingEmployeeDetail> T0130HrmsTrainingEmployeeDetails { get; set; } = new List<T0130HrmsTrainingEmployeeDetail>();

    public virtual ICollection<T0130LtaForDependant> T0130LtaForDependants { get; set; } = new List<T0130LtaForDependant>();

    public virtual ICollection<T0130LtaJurneyDetail> T0130LtaJurneyDetails { get; set; } = new List<T0130LtaJurneyDetail>();

    public virtual ICollection<T0130TravelApprovalDetail> T0130TravelApprovalDetails { get; set; } = new List<T0130TravelApprovalDetail>();

    public virtual ICollection<T0130TravelHelpDesk> T0130TravelHelpDesks { get; set; } = new List<T0130TravelHelpDesk>();

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

    public virtual ICollection<T0150EmpWorkDetail> T0150EmpWorkDetails { get; set; } = new List<T0150EmpWorkDetail>();

    public virtual ICollection<T0150HrmsTrainingAnswer> T0150HrmsTrainingAnswers { get; set; } = new List<T0150HrmsTrainingAnswer>();

    public virtual ICollection<T0150TravelSettlementApprovalExpense> T0150TravelSettlementApprovalExpenses { get; set; } = new List<T0150TravelSettlementApprovalExpense>();

    public virtual ICollection<T0160HrmsManagerFeedbackResponse> T0160HrmsManagerFeedbackResponses { get; set; } = new List<T0160HrmsManagerFeedbackResponse>();

    public virtual ICollection<T0160HrmsTrainingQuestionnaireResponse> T0160HrmsTrainingQuestionnaireResponses { get; set; } = new List<T0160HrmsTrainingQuestionnaireResponse>();

    public virtual ICollection<T0160LateApproval> T0160LateApprovals { get; set; } = new List<T0160LateApproval>();

    public virtual ICollection<T0160OtApproval> T0160OtApprovals { get; set; } = new List<T0160OtApproval>();

    public virtual ICollection<T0180Bonu> T0180Bonus { get; set; } = new List<T0180Bonu>();

    public virtual ICollection<T0190EmpArrearDetail> T0190EmpArrearDetails { get; set; } = new List<T0190EmpArrearDetail>();

    public virtual ICollection<T0190MonthlyAdDetailImport> T0190MonthlyAdDetailImports { get; set; } = new List<T0190MonthlyAdDetailImport>();

    public virtual ICollection<T0190MonthlyPresentImport> T0190MonthlyPresentImports { get; set; } = new List<T0190MonthlyPresentImport>();

    public virtual ICollection<T0190TaxPlanning> T0190TaxPlannings { get; set; } = new List<T0190TaxPlanning>();

    public virtual ICollection<T0200EmpExitApplication> T0200EmpExitApplicationEmps { get; set; } = new List<T0200EmpExitApplication>();

    public virtual ICollection<T0200EmpExitApplication> T0200EmpExitApplicationSEmps { get; set; } = new List<T0200EmpExitApplication>();

    public virtual ICollection<T0200ExitInterview> T0200ExitInterviews { get; set; } = new List<T0200ExitInterview>();

    public virtual ICollection<T0200MonthlySalary> T0200MonthlySalaries { get; set; } = new List<T0200MonthlySalary>();

    public virtual ICollection<T0200MonthlySalaryDaily> T0200MonthlySalaryDailies { get; set; } = new List<T0200MonthlySalaryDaily>();

    public virtual ICollection<T0200MonthlySalaryLeave> T0200MonthlySalaryLeaves { get; set; } = new List<T0200MonthlySalaryLeave>();

    public virtual ICollection<T0201MonthlySalarySett> T0201MonthlySalarySetts { get; set; } = new List<T0201MonthlySalarySett>();

    public virtual ICollection<T0210LwpConsideredSameSalaryCutoff> T0210LwpConsideredSameSalaryCutoffs { get; set; } = new List<T0210LwpConsideredSameSalaryCutoff>();

    public virtual ICollection<T0210MonthlyAdDetailDaily> T0210MonthlyAdDetailDailies { get; set; } = new List<T0210MonthlyAdDetailDaily>();

    public virtual ICollection<T0210MonthlyAdDetailImport> T0210MonthlyAdDetailImports { get; set; } = new List<T0210MonthlyAdDetailImport>();

    public virtual ICollection<T0210MonthlyAdDetail> T0210MonthlyAdDetails { get; set; } = new List<T0210MonthlyAdDetail>();

    public virtual ICollection<T0210MonthlyLeaveDetail> T0210MonthlyLeaveDetails { get; set; } = new List<T0210MonthlyLeaveDetail>();

    public virtual ICollection<T0210MonthlyPresentCalculation> T0210MonthlyPresentCalculations { get; set; } = new List<T0210MonthlyPresentCalculation>();

    public virtual ICollection<T0210MonthlyReimDetail> T0210MonthlyReimDetails { get; set; } = new List<T0210MonthlyReimDetail>();

    public virtual ICollection<T0230MonthlyClaimPaymentDetail> T0230MonthlyClaimPaymentDetails { get; set; } = new List<T0230MonthlyClaimPaymentDetail>();

    public virtual ICollection<T0230TdsChallanDetail> T0230TdsChallanDetails { get; set; } = new List<T0230TdsChallanDetail>();

    public virtual ICollection<T0240LtaMedicalTransaction> T0240LtaMedicalTransactions { get; set; } = new List<T0240LtaMedicalTransaction>();

    public virtual ICollection<T0250ChangePasswordHistory> T0250ChangePasswordHistories { get; set; } = new List<T0250ChangePasswordHistory>();

    public virtual ICollection<T0251ItPaidDetail> T0251ItPaidDetails { get; set; } = new List<T0251ItPaidDetail>();

    public virtual ICollection<T0302PaymentProcessTravelDetail> T0302PaymentProcessTravelDetails { get; set; } = new List<T0302PaymentProcessTravelDetail>();

    public virtual ICollection<T9999SalaryExportDetail> T9999SalaryExportDetails { get; set; } = new List<T9999SalaryExportDetail>();

    public virtual T0040TallyLedMaster? TallyLed { get; set; }

    public virtual T0040TypeMaster? Type { get; set; }
}
