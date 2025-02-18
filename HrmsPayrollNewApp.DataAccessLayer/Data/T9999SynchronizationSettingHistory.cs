using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T9999SynchronizationSettingHistory
{
    public string? EmailId { get; set; }

    public string? From1 { get; set; }

    public string? To1 { get; set; }

    public string? From2 { get; set; }

    public string? To2 { get; set; }

    public string? From3 { get; set; }

    public string? To3 { get; set; }

    public string? BranchCode { get; set; }

    public decimal Interval1 { get; set; }

    public decimal Interval2 { get; set; }

    public decimal Interval3 { get; set; }
}
