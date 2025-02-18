using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040HrmsAwardMaster
{
    public decimal AwardsId { get; set; }

    public decimal CmpId { get; set; }

    public string AwardName { get; set; } = null!;

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual ICollection<T0060HrmsEmployeeReward> T0060HrmsEmployeeRewards { get; set; } = new List<T0060HrmsEmployeeReward>();
}
