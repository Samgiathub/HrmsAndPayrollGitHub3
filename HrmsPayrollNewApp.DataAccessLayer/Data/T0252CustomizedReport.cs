using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0252CustomizedReport
{
    public decimal TranId { get; set; }

    public decimal CmpId { get; set; }

    public string Name { get; set; } = null!;

    public string ReportType { get; set; } = null!;

    public string ReportField { get; set; } = null!;

    public DateTime Modifydate { get; set; }

    public decimal UserId { get; set; }
}
