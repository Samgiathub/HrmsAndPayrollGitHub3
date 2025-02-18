using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040BonusLunchSlab
{
    public int TranId { get; set; }

    public decimal? CmpId { get; set; }

    public DateTime? ForDate { get; set; }

    public decimal? EmpId { get; set; }

    public string? Gender { get; set; }

    public string? Designation { get; set; }

    public decimal? FromTime { get; set; }

    public decimal? ToTime { get; set; }

    public decimal? BonusAmount { get; set; }
}
