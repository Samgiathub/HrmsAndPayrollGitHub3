using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0115BalanceScoreCardSettingDetailsLevel
{
    public decimal TranId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public decimal BscSettingDetailId { get; set; }

    public decimal KpiId { get; set; }

    public string? BscObjective { get; set; }

    public string? BscMeasure { get; set; }

    public string? BscTarget { get; set; }

    public string? BscFormula { get; set; }

    public decimal? BscWeight { get; set; }

    public byte? RptLevel { get; set; }

    public decimal? BscLevelId { get; set; }

    public virtual T0110BalanceScoreCardSettingApproval? BscLevel { get; set; }

    public virtual T0095BalanceScoreCardSettingDetail BscSettingDetail { get; set; } = null!;

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster Emp { get; set; } = null!;

    public virtual T0040KpiMaster Kpi { get; set; } = null!;

    public virtual ICollection<T0115BscScoringKeyLevel> T0115BscScoringKeyLevels { get; set; } = new List<T0115BscScoringKeyLevel>();
}
