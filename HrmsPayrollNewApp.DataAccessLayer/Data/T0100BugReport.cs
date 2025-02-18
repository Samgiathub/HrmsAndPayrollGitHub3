using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0100BugReport
{
    public decimal BugId { get; set; }

    public string BugCode { get; set; } = null!;

    public string BugType { get; set; } = null!;

    public string BugDescription { get; set; } = null!;

    public string BugShanpShort { get; set; } = null!;

    public string BugSeverity { get; set; } = null!;

    public string BugPriority { get; set; } = null!;

    public string BugReportedBy { get; set; } = null!;

    public DateTime BugReportedOn { get; set; }

    public string BugAssignedOn { get; set; } = null!;

    public DateTime? BugExpFixDate { get; set; }

    public string BugFixedBy { get; set; } = null!;

    public DateTime? BugFixedOn { get; set; }

    public string BugStatus { get; set; } = null!;

    public string BugComment { get; set; } = null!;
}
