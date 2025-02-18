using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0110BalanceScoreCardEvaluationApproval
{
    public decimal EmpBscReviewLevelId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public decimal? SEmpId { get; set; }

    public decimal? EmpBscReviewId { get; set; }

    public DateTime? ApprovalDate { get; set; }

    public string? ApprovalComments { get; set; }

    public decimal? LoginId { get; set; }

    public int? RptLevel { get; set; }

    public int? ApprovalStatus { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster Emp { get; set; } = null!;

    public virtual T0095BalanceScoreCardEvaluation? EmpBscReview { get; set; }

    public virtual ICollection<T0115BalanceScoreCardEvaluationDetailsLevel> T0115BalanceScoreCardEvaluationDetailsLevels { get; set; } = new List<T0115BalanceScoreCardEvaluationDetailsLevel>();
}
