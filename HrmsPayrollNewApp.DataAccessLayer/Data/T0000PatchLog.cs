using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0000PatchLog
{
    public long Id { get; set; }

    public DateTime? LogDate { get; set; }

    public DateTime? FileDate { get; set; }

    public string? FilePath { get; set; }

    public string? AppVer { get; set; }
}
