using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040HrmsRewardValue
{
    public decimal RewardValuesId { get; set; }

    public decimal CmpId { get; set; }

    public string? RewardValuesName { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;
}
