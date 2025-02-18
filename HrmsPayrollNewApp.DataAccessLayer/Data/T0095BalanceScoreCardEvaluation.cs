using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0095BalanceScoreCardEvaluation
{
    public decimal EmpBscReviewId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public int FinYear { get; set; }

    public int ReviewType { get; set; }

    public decimal ReviewStatus { get; set; }

    public string? EmpComment { get; set; }

    public string? ManagerComment { get; set; }

    public DateTime CreatedDate { get; set; }

    public decimal CreatedBy { get; set; }

    public DateTime? ModifiedDate { get; set; }

    public decimal? ModifiedBy { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster Emp { get; set; } = null!;

    public virtual ICollection<T0100BalanceScoreCardEvaluationDetail> T0100BalanceScoreCardEvaluationDetails { get; set; } = new List<T0100BalanceScoreCardEvaluationDetail>();

    public virtual ICollection<T0110BalanceScoreCardEvaluationApproval> T0110BalanceScoreCardEvaluationApprovals { get; set; } = new List<T0110BalanceScoreCardEvaluationApproval>();
}
