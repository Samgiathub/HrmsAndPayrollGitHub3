using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0251ReportSetting
{
    public decimal TranId { get; set; }

    public decimal CmpId { get; set; }

    public string ReportName { get; set; } = null!;

    public string ReportFileName { get; set; } = null!;

    public DateTime ModifyDate { get; set; }

    public decimal Format { get; set; }
}
