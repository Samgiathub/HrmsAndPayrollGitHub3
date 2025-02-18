using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0110BalanceScoreCardSettingApproval
{
    public decimal BscLevelId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public decimal? SEmpId { get; set; }

    public decimal? BscSettingId { get; set; }

    public DateTime? ApprovalDate { get; set; }

    public string? ApprovalComments { get; set; }

    public decimal? LoginId { get; set; }

    public int RptLevel { get; set; }

    public int ApprovalStatus { get; set; }

    public virtual T0090BalanceScoreCardSetting? BscSetting { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster Emp { get; set; } = null!;

    public virtual ICollection<T0115BalanceScoreCardSettingDetailsLevel> T0115BalanceScoreCardSettingDetailsLevels { get; set; } = new List<T0115BalanceScoreCardSettingDetailsLevel>();

    public virtual ICollection<T0115BscScoringKeyLevel> T0115BscScoringKeyLevels { get; set; } = new List<T0115BscScoringKeyLevel>();
}
