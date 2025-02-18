using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T9999AxReportSetting
{
    public decimal AxId { get; set; }

    public string AxType { get; set; } = null!;

    public string SpName { get; set; } = null!;

    public string? Parameter { get; set; }

    public DateTime ModifyDate { get; set; }

    public string? Format { get; set; }
}
