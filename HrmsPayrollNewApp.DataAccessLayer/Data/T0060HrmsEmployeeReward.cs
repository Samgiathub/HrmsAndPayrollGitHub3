using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0060HrmsEmployeeReward
{
    public decimal EmpRewardId { get; set; }

    public decimal CmpId { get; set; }

    public DateTime? FromDate { get; set; }

    public DateTime? ToDate { get; set; }

    public string? EmployeeId { get; set; }

    public int? Type { get; set; }

    public string? RewardValuesId { get; set; }

    public int? EmpRewardRating { get; set; }

    public decimal? AwardsId { get; set; }

    public string? Comments { get; set; }

    public string? RewardAttachment { get; set; }

    public virtual T0040HrmsAwardMaster? Awards { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;
}
