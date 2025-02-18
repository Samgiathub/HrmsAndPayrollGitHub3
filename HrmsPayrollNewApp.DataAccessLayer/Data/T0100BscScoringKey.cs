using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0100BscScoringKey
{
    public decimal BscScoringKeyId { get; set; }

    public decimal CmpId { get; set; }

    public decimal? BscSettingDetailId { get; set; }

    public string? KeyName { get; set; }

    public string? KeyValue { get; set; }

    public virtual T0095BalanceScoreCardSettingDetail? BscSettingDetail { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;
}
