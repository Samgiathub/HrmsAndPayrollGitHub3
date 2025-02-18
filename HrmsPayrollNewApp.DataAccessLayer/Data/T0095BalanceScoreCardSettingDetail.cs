using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0095BalanceScoreCardSettingDetail
{
    public decimal BscSettingDetailId { get; set; }

    public decimal CmpId { get; set; }

    public decimal BscSettingId { get; set; }

    public decimal EmpId { get; set; }

    public decimal KpiId { get; set; }

    public string? BscObjective { get; set; }

    public string? BscMeasure { get; set; }

    public string? BscTarget { get; set; }

    public string? BscFormula { get; set; }

    public decimal? BscWeight { get; set; }

    public virtual T0090BalanceScoreCardSetting BscSetting { get; set; } = null!;

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster Emp { get; set; } = null!;

    public virtual ICollection<T0100BalanceScoreCardEvaluationDetail> T0100BalanceScoreCardEvaluationDetails { get; set; } = new List<T0100BalanceScoreCardEvaluationDetail>();

    public virtual ICollection<T0100BscScoringKey> T0100BscScoringKeys { get; set; } = new List<T0100BscScoringKey>();

    public virtual ICollection<T0115BalanceScoreCardEvaluationDetailsLevel> T0115BalanceScoreCardEvaluationDetailsLevels { get; set; } = new List<T0115BalanceScoreCardEvaluationDetailsLevel>();

    public virtual ICollection<T0115BalanceScoreCardSettingDetailsLevel> T0115BalanceScoreCardSettingDetailsLevels { get; set; } = new List<T0115BalanceScoreCardSettingDetailsLevel>();

    public virtual ICollection<T0115BscScoringKeyLevel> T0115BscScoringKeyLevels { get; set; } = new List<T0115BscScoringKeyLevel>();
}
