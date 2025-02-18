using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0100BalanceScoreCardEvaluationDetail
{
    public decimal EmpBscReviewDetailId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public decimal? EmpBscReviewId { get; set; }

    public decimal? BscSettingDetailId { get; set; }

    public string? Actual { get; set; }

    public string? Score { get; set; }

    public decimal? WeightedScore { get; set; }

    public virtual T0095BalanceScoreCardSettingDetail? BscSettingDetail { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster Emp { get; set; } = null!;

    public virtual T0095BalanceScoreCardEvaluation? EmpBscReview { get; set; }

    public virtual ICollection<T0115BalanceScoreCardEvaluationDetailsLevel> T0115BalanceScoreCardEvaluationDetailsLevels { get; set; } = new List<T0115BalanceScoreCardEvaluationDetailsLevel>();
}
