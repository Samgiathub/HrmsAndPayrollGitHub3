using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0050LeaveCfMonthlySetting
{
    public decimal LeaveTranId { get; set; }

    public decimal LeaveId { get; set; }

    public DateTime ForDate { get; set; }

    public decimal CmpId { get; set; }

    public decimal CfMDays { get; set; }

    public DateTime? EffectiveDate { get; set; }

    public decimal? TypeId { get; set; }

    public decimal? CfMDaysAfterJoining { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0040LeaveMaster Leave { get; set; } = null!;
}
