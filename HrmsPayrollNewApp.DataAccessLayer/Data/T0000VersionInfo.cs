using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0000VersionInfo
{
    public decimal VersionId { get; set; }

    public string VersionNo { get; set; } = null!;

    public DateTime LastUpdate { get; set; }

    public string DatabaseName { get; set; } = null!;

    public string ServerName { get; set; } = null!;
}
