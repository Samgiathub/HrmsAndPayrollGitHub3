using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0115EmpProbationMasterLevel
{
    public decimal TranId { get; set; }

    public decimal EmpId { get; set; }

    public decimal CmpId { get; set; }

    public decimal ProbationStatus { get; set; }

    public DateTime EvaluationDate { get; set; }

    public decimal? ExtendPeriod { get; set; }

    public decimal OldProbationPeriod { get; set; }

    public DateTime? OldProbationEndDate { get; set; }

    public DateTime? NewProbationEndDate { get; set; }

    public string? MajorStrength { get; set; }

    public string? MajorWeakness { get; set; }

    public string? AppraiserRemarks { get; set; }

    public string? AppraisalReviewerRemarks { get; set; }

    public string? Flag { get; set; }

    public string? TrainingId { get; set; }

    public decimal SEmpId { get; set; }

    public string Status { get; set; } = null!;

    public decimal RptLevel { get; set; }

    public DateTime SystemDatetime { get; set; }

    public string? ApprovalPeriodType { get; set; }

    public decimal? EmpTypeId { get; set; }

    public decimal ProbationEvaluationId { get; set; }

    public decimal? FinalReview { get; set; }

    public string? ReviewType { get; set; }

    public byte IsSelfRating { get; set; }

    public string AttachDocs { get; set; } = null!;

    public DateTime? ConfirmationDate { get; set; }

    public virtual ICollection<T0115EmpProbationAttributeDetailLevel> T0115EmpProbationAttributeDetailLevels { get; set; } = new List<T0115EmpProbationAttributeDetailLevel>();

    public virtual ICollection<T0115EmpProbationSkillDetailLevel> T0115EmpProbationSkillDetailLevels { get; set; } = new List<T0115EmpProbationSkillDetailLevel>();
}
