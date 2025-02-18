using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0240DefaultReport
{
    public int RptId { get; set; }

    public string ReportName { get; set; } = null!;

    public string RptAlias { get; set; } = null!;
}
