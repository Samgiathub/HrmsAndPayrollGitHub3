using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0052HrmsInitiateReward
{
    public decimal InitRewardId { get; set; }

    public decimal? CmpId { get; set; }

    public DateTime? FromDate { get; set; }

    public DateTime? ToDate { get; set; }

    public string? DeptId { get; set; }

    public string? Department { get; set; }

    public string? CatId { get; set; }

    public string? Category { get; set; }
}
