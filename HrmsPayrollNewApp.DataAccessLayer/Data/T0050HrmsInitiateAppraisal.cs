using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0050HrmsInitiateAppraisal
{
    public decimal InitiateId { get; set; }

    public decimal CmpId { get; set; }

    public decimal? EmpId { get; set; }

    public decimal? AppraiserId { get; set; }

    public DateTime? SaStartdate { get; set; }

    public DateTime? SaEnddate { get; set; }

    public string? SaEmpComments { get; set; }

    public string? SaAppComments { get; set; }

    public int? SaStatus { get; set; }

    public decimal? KpaScore { get; set; }

    public decimal? KpaFinal { get; set; }

    public DateTime? SaSubmissionDate { get; set; }

    public DateTime? SaApprovedDate { get; set; }

    public decimal? PfScore { get; set; }

    public decimal? PfFinal { get; set; }

    public decimal? PoScore { get; set; }

    public decimal? PoFinal { get; set; }

    public decimal? OverallScore { get; set; }

    public decimal? AchivementId { get; set; }

    public string? AppraiserComment { get; set; }

    public int? PromoYesNo { get; set; }

    public decimal? PromoDesig { get; set; }

    public DateTime? PromoWef { get; set; }

    public int? JrYesNo { get; set; }

    public DateTime? JrFrom { get; set; }

    public DateTime? JrTo { get; set; }

    public int? IncYesNo { get; set; }

    public string? IncReason { get; set; }

    public string? ReviewerComment { get; set; }

    public DateTime? AppraiserDate { get; set; }

    public decimal? SaApprovedBy { get; set; }

    public decimal? PerApprovedBy { get; set; }

    public int? OverallStatus { get; set; }

    public string? GhComment { get; set; }

    public int? SaSendToRm { get; set; }

    public int? SendToHod { get; set; }

    public string? HodComment { get; set; }

    public DateTime? HodApprovedOn { get; set; }

    public decimal? HodApprovedBy { get; set; }

    public decimal? HodId { get; set; }

    public int? DirectScore { get; set; }

    public decimal? RmScore { get; set; }

    public decimal? HodScore { get; set; }

    public decimal? GroupHeadScore { get; set; }

    public int? FinalEvaluation { get; set; }

    public int? FinancialYear { get; set; }

    public int? DurationFromMonth { get; set; }

    public int? DurationToMonth { get; set; }

    public decimal? PromoGrade { get; set; }

    public decimal? GhId { get; set; }

    public byte? RmRequired { get; set; }

    public int? EmpEngagement { get; set; }

    public string? EmpEngagementComment { get; set; }

    public decimal? HaoId { get; set; }

    public decimal? OverallScoreRm { get; set; }

    public decimal? OverallScoreHod { get; set; }

    public decimal? OverallScoreGh { get; set; }

    public decimal? OverallScoreMd { get; set; }

    public string? MdComments { get; set; }

    public int? SendDirectlyPerformanceAssessment { get; set; }

    public int? AchivementIdRm { get; set; }

    public int? AchivementIdHod { get; set; }

    public int? AchivementIdGh { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual ICollection<T0050HrmsEmpOaFeedback> T0050HrmsEmpOaFeedbacks { get; set; } = new List<T0050HrmsEmpOaFeedback>();

    public virtual ICollection<T0052EmpSelfAppraisal> T0052EmpSelfAppraisals { get; set; } = new List<T0052EmpSelfAppraisal>();

    public virtual ICollection<T0052HrmsAppTrainDetail> T0052HrmsAppTrainDetails { get; set; } = new List<T0052HrmsAppTrainDetail>();

    public virtual ICollection<T0052HrmsAppTrainingDetail> T0052HrmsAppTrainingDetails { get; set; } = new List<T0052HrmsAppTrainingDetail>();

    public virtual ICollection<T0052HrmsAppTraining> T0052HrmsAppTrainings { get; set; } = new List<T0052HrmsAppTraining>();

    public virtual ICollection<T0052HrmsAttributeFeedback> T0052HrmsAttributeFeedbacks { get; set; } = new List<T0052HrmsAttributeFeedback>();

    public virtual ICollection<T0052HrmsKpa> T0052HrmsKpas { get; set; } = new List<T0052HrmsKpa>();

    public virtual ICollection<T0052HrmsPerformanceAnswer> T0052HrmsPerformanceAnswers { get; set; } = new List<T0052HrmsPerformanceAnswer>();

    public virtual ICollection<T0110HrmsAppraisalPlanDetail> T0110HrmsAppraisalPlanDetails { get; set; } = new List<T0110HrmsAppraisalPlanDetail>();
}
