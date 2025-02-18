using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0050AppraisalLimitSetting
{
    public decimal LimitId { get; set; }

    public decimal CmpId { get; set; }

    public decimal? ScoreLimitKpa { get; set; }

    public decimal? ScoreLimitPa { get; set; }

    public decimal? ScoreLimitPoA { get; set; }

    public decimal? RecommendLimitSkill { get; set; }

    public decimal? RecommendLimitGm { get; set; }

    public decimal? JoiningDateLimit { get; set; }

    public decimal? KpaLimit { get; set; }

    public int? KpaMasterYes { get; set; }

    public bool? KpaDefault { get; set; }

    public bool? KpaScore { get; set; }

    public bool? KpaAllowEmp { get; set; }

    public bool? SaSubCriteria { get; set; }

    public bool? OaViewByManager { get; set; }

    public bool? KpaAllowEmpScoreDisplay { get; set; }

    public bool? KpaAllowRmscoreDisplay { get; set; }

    public bool? KpaPercentage { get; set; }

    public decimal? KpaPerScore { get; set; }

    public bool? KpaAllowAddKpa { get; set; }

    public int? EmpAssessApproveDays { get; set; }

    public int? EmpPaApproveRmDays { get; set; }

    public int? PaHodDays { get; set; }

    public int? PaGhDays { get; set; }

    public DateTime? EffectiveDate { get; set; }

    public int? MultipleEvaluation { get; set; }

    public string? InterimEvaluationBy { get; set; }

    public string? InterimDisplayTab { get; set; }

    public bool? DisplayPreviousKpa { get; set; }

    public bool? DisplayPreviousKpayear { get; set; }

    public string? FinalDisplayTab { get; set; }

    public decimal SendDeptWise { get; set; }

    public decimal SelfAssessmentWithAnswer { get; set; }

    public decimal ScoreUsingFormula { get; set; }

    public decimal ShowKpaMeasure { get; set; }

    public decimal? TotalKpaWeightage { get; set; }

    public int MinKpa { get; set; }

    public int MaxKpa { get; set; }

    public int ShowCompletionDate { get; set; }

    public int ShowAttachDocument { get; set; }

    public int ShowJustification { get; set; }

    public double MinKpaweightage { get; set; }

    public double MaxKpaweightage { get; set; }

    public int? ScoreUsingStdformula { get; set; }

    public int? ScoreUsingPerFormula { get; set; }

    public int? ValidityPeriodType { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;
}
