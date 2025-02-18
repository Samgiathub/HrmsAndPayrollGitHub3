using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0115BscScoringKeyLevel
{
    public decimal RowId { get; set; }

    public decimal CmpId { get; set; }

    public decimal TranId { get; set; }

    public decimal? BscSettingDetailId { get; set; }

    public string? KeyName { get; set; }

    public string? KeyValue { get; set; }

    public decimal? BscLevelId { get; set; }

    public int? RptLevel { get; set; }

    public virtual T0110BalanceScoreCardSettingApproval? BscLevel { get; set; }

    public virtual T0095BalanceScoreCardSettingDetail? BscSettingDetail { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0115BalanceScoreCardSettingDetailsLevel Tran { get; set; } = null!;
}
