using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0250CustomizedReport
{
    public int? ReportId { get; set; }

    public string? ReportName { get; set; }

    public int? TypeId { get; set; }

    public string? ReportType { get; set; }

    public int? FormId { get; set; }
}
