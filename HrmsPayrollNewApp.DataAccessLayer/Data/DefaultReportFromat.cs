using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class DefaultReportFromat
{
    public decimal TransId { get; set; }

    public decimal? EmpId { get; set; }

    public decimal? UserId { get; set; }

    public decimal? ReportId { get; set; }

    public string? ReportName { get; set; }

    public string? Ddlformat { get; set; }

    public string? DdlType { get; set; }

    public DateTime? SysDate { get; set; }
}
