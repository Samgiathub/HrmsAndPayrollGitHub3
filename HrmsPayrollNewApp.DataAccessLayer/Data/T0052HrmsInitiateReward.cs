using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0052HrmsInitiateReward
{
    public decimal InitRewardId { get; set; }

    public decimal? CmpId { get; set; }

    public DateTime? FromDate { get; set; }

    public DateTime? ToDate { get; set; }

    public string? DeptId { get; set; }

    public string? CatId { get; set; }

    public virtual T0010CompanyMaster? Cmp { get; set; }
}
