using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0050AdMaster
{
    public decimal AdId { get; set; }

    public decimal CmpId { get; set; }

    public string AdName { get; set; } = null!;

    public string AdSortName { get; set; } = null!;

    public decimal AdLevel { get; set; }

    public string AdFlag { get; set; } = null!;

    public string AdCalculateOn { get; set; } = null!;

    public string AdMode { get; set; } = null!;

    public decimal AdPercentage { get; set; }

    public decimal AdAmount { get; set; }

    public decimal AdActive { get; set; }

    public decimal AdMaxLimit { get; set; }

    public decimal? AdDefId { get; set; }

    public decimal? AdNotEffectOnPt { get; set; }

    public decimal? AdNotEffectSalary { get; set; }

    public decimal? AdEffectOnOt { get; set; }

    public decimal? AdEffectOnExtraDay { get; set; }

    public byte? AdEffectOnLate { get; set; }

    public byte? AdEffectOnLeave { get; set; }

    public byte? AdEffectOnBonus { get; set; }

    public byte? AdEffectOnGratuity { get; set; }

    public byte? AdEffectOnShortFall { get; set; }

    public byte? AdItDefId { get; set; }

    public byte? AdRptDefId { get; set; }

    public decimal? AdEffectOnCtc { get; set; }

    public string? AdEffectMonth { get; set; }

    public string? LeaveType { get; set; }

    public string? AdCalType { get; set; }

    public string? AdEffectFrom { get; set; }

    public decimal? EffectNetSalary { get; set; }

    public decimal? AdEffectOnTds { get; set; }

    public decimal? AdNotEffectOnLwp { get; set; }

    public byte AdPartOfCtc { get; set; }

    public byte ForFnf { get; set; }

    public byte NotEffectOnMonthlyCtc { get; set; }

    public byte IsYearly { get; set; }

    public byte NotEffectOnBasicCalculation { get; set; }

    public byte? AttachedMandatory { get; set; }

    public byte? AutoPaid { get; set; }

    public byte? DisplayBalance { get; set; }

    public string? AllowanceType { get; set; }

    public byte? NegativeBalance { get; set; }

    public decimal? LtaLeaveAppLimit { get; set; }

    public decimal? NoOfMonth { get; set; }

    public byte? DisplayInSalary { get; set; }

    public byte AddInSalAmt { get; set; }

    public byte? IsOptional { get; set; }

    public string? AdCode { get; set; }

    public int MonthlyLimit { get; set; }

    public byte DefineReimExpenseLimit { get; set; }

    public byte AdEffectOnNighthalt { get; set; }

    public byte AdEffectOnGatepass { get; set; }

    public byte AdEffectOnEsic { get; set; }

    public byte IsCalculatedOnImportedValue { get; set; }

    public byte AutoDedTds { get; set; }

    public byte? IsRounding { get; set; }

    public string? ReimGuideline { get; set; }

    public byte IsClaimBase { get; set; }

    public byte NotDisplayAutoCreditAmountIt { get; set; }

    public byte HideInReports { get; set; }

    public string? GujaratiAlias { get; set; }

    public byte ShowInPaySlip { get; set; }

    public byte IsQuarterlyReim { get; set; }

    public byte ProrataOnSalaryStructure { get; set; }

    public decimal ClaimId { get; set; }

    public int? IsBonusCalDays { get; set; }

    public int? BonusDays { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual ICollection<EmpForFnfAllowance> EmpForFnfAllowances { get; set; } = new List<EmpForFnfAllowance>();

    public virtual ICollection<T0040AdFormulaSetting> T0040AdFormulaSettings { get; set; } = new List<T0040AdFormulaSetting>();

    public virtual ICollection<T0040AdSlabSetting> T0040AdSlabSettings { get; set; } = new List<T0040AdSlabSetting>();

    public virtual ICollection<T0040ReimClaimSetting> T0040ReimClaimSettings { get; set; } = new List<T0040ReimClaimSetting>();

    public virtual ICollection<T0050AdExpenseLimitMaster> T0050AdExpenseLimitMasters { get; set; } = new List<T0050AdExpenseLimitMaster>();

    public virtual ICollection<T0055Reimbursement> T0055Reimbursements { get; set; } = new List<T0055Reimbursement>();

    public virtual ICollection<T0060EffectAdMaster> T0060EffectAdMasterAds { get; set; } = new List<T0060EffectAdMaster>();

    public virtual ICollection<T0060EffectAdMaster> T0060EffectAdMasterEffectAds { get; set; } = new List<T0060EffectAdMaster>();

    public virtual ICollection<T0060RimbEffectAdMaster> T0060RimbEffectAdMasters { get; set; } = new List<T0060RimbEffectAdMaster>();

    public virtual ICollection<T0070ItMaster> T0070ItMasters { get; set; } = new List<T0070ItMaster>();

    public virtual ICollection<T0095ReimOpening> T0095ReimOpenings { get; set; } = new List<T0095ReimOpening>();

    public virtual ICollection<T0100AdGradeBranchWise> T0100AdGradeBranchWises { get; set; } = new List<T0100AdGradeBranchWise>();

    public virtual ICollection<T0100AnualBonu> T0100AnualBonus { get; set; } = new List<T0100AnualBonu>();

    public virtual ICollection<T0100ArApplicationDetail> T0100ArApplicationDetails { get; set; } = new List<T0100ArApplicationDetail>();

    public virtual ICollection<T0100EmpEarnDeduction> T0100EmpEarnDeductions { get; set; } = new List<T0100EmpEarnDeduction>();

    public virtual ICollection<T0100ItFormDesign> T0100ItFormDesigns { get; set; } = new List<T0100ItFormDesign>();

    public virtual ICollection<T0100RcApplication> T0100RcApplications { get; set; } = new List<T0100RcApplication>();

    public virtual ICollection<T0110EmpEarnDeductionRevised> T0110EmpEarnDeductionReviseds { get; set; } = new List<T0110EmpEarnDeductionRevised>();

    public virtual ICollection<T0110RcDependantDetail> T0110RcDependantDetails { get; set; } = new List<T0110RcDependantDetail>();

    public virtual ICollection<T0110RcLtaTravelDetail> T0110RcLtaTravelDetails { get; set; } = new List<T0110RcLtaTravelDetail>();

    public virtual ICollection<T0110RcReimbursementDetail> T0110RcReimbursementDetails { get; set; } = new List<T0110RcReimbursementDetail>();

    public virtual ICollection<T0120GradewiseAllowance> T0120GradewiseAllowances { get; set; } = new List<T0120GradewiseAllowance>();

    public virtual ICollection<T0130ArApprovalDetail> T0130ArApprovalDetails { get; set; } = new List<T0130ArApprovalDetail>();

    public virtual ICollection<T0140ReimClaimTransacation> T0140ReimClaimTransacations { get; set; } = new List<T0140ReimClaimTransacation>();

    public virtual ICollection<T0190MonthlyAdDetailImport> T0190MonthlyAdDetailImports { get; set; } = new List<T0190MonthlyAdDetailImport>();

    public virtual ICollection<T0190ProductionBonusVariableImport> T0190ProductionBonusVariableImports { get; set; } = new List<T0190ProductionBonusVariableImport>();

    public virtual ICollection<T0210MonthlyAdDetailDaily> T0210MonthlyAdDetailDailies { get; set; } = new List<T0210MonthlyAdDetailDaily>();

    public virtual ICollection<T0210MonthlyAdDetailImport> T0210MonthlyAdDetailImports { get; set; } = new List<T0210MonthlyAdDetailImport>();

    public virtual ICollection<T0210MonthlyAdDetail> T0210MonthlyAdDetails { get; set; } = new List<T0210MonthlyAdDetail>();
}
