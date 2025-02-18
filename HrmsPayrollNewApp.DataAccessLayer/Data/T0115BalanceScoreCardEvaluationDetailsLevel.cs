using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0115BalanceScoreCardEvaluationDetailsLevel
{
    public decimal TranId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public decimal? EmpBscReviewDetailId { get; set; }

    public decimal? EmpBscReviewLevelId { get; set; }

    public int? RptLevel { get; set; }

    public decimal? BscSettingDetailId { get; set; }

    public string? Actual { get; set; }

    public string? SupScore { get; set; }

    public decimal? WeightedScore { get; set; }

    public virtual T0095BalanceScoreCardSettingDetail? BscSettingDetail { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster Emp { get; set; } = null!;

    public virtual T0100BalanceScoreCardEvaluationDetail? EmpBscReviewDetail { get; set; }

    public virtual T0110BalanceScoreCardEvaluationApproval? EmpBscReviewLevel { get; set; }
}
