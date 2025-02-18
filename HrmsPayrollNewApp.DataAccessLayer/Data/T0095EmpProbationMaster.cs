using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0095EmpProbationMaster
{
    public decimal ProbationEvaluationId { get; set; }

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

    public decimal SupervisorId { get; set; }

    public string? Flag { get; set; }

    public string? TrainingId { get; set; }

    public string? ApprovalPeriodType { get; set; }

    public decimal? EmpTypeId { get; set; }

    public decimal? FinalReview { get; set; }

    public string? ReviewType { get; set; }

    public string AttachDocs { get; set; } = null!;

    public DateTime? ConfirmationDate { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster Emp { get; set; } = null!;

    public virtual ICollection<T0100EmpProbationAttributeDetail> T0100EmpProbationAttributeDetails { get; set; } = new List<T0100EmpProbationAttributeDetail>();

    public virtual ICollection<T0100EmpProbationSkillDetail> T0100EmpProbationSkillDetails { get; set; } = new List<T0100EmpProbationSkillDetail>();
}
