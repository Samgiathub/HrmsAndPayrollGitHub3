using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0030ReportHeaderMaster
{
    public decimal ReportId { get; set; }

    public decimal? CmpId { get; set; }

    public string? ReportHeaderName { get; set; }

    public DateTime? Systemdate { get; set; }
}
