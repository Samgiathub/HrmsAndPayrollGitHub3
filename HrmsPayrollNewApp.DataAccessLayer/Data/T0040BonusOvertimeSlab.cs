using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040BonusOvertimeSlab
{
    public int TranId { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? BranchId { get; set; }

    public DateTime? EffectiveDate { get; set; }

    public string? StartTime { get; set; }

    public decimal? FromMin { get; set; }

    public decimal? ToMin { get; set; }

    public decimal? Amount { get; set; }
}
